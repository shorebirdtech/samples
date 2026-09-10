import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:shorebird_runner/game/components/components.dart';
import 'package:shorebird_runner/game/control_scheme.dart';
import 'package:shorebird_runner/game/floating_text.dart';
import 'package:shorebird_runner/game/utils/utils.dart';

/// The core Shorebird Runner engine.
/// Engineered for 120 FPS buttery-smooth performance, zero per-frame text layouts,
/// clamped delta timing, responsive multi-input controls (Keyboard, Swipe, Tap),
/// magnetic Hot Reload powerups, and Subway Surfers style jump/slide clearances.
class ShorebirdRunnerGame extends FlameGame
    with KeyboardEvents, TapCallbacks, DragCallbacks {
  final void Function(int score, int patches, LevelConfig level) onGameOver;
  final void Function(int score, int patches, LevelConfig level, bool isAlive)?
      onScoreUpdate;
  final ControlScheme controlScheme;
  final PlayerSkin skin;
  final String? playerTag;

  ShorebirdRunnerGame({
    required this.onGameOver,
    this.onScoreUpdate,
    this.controlScheme = ControlScheme.both,
    this.skin = PlayerSkin.blueBird,
    this.playerTag,
  });

  // State
  int score = 0;
  int highScore = 0;
  int totalPatches = 0;
  LevelConfig currentLevel = GameConfig.levels.first;
  bool _isOver = false;
  bool get isOver => _isOver;
  double _elapsed = 0;
  int _combo = 0;
  double _obstacleTimer = 0;
  double _patchTimer = 0;
  double _timePointTimer = 0;
  double _scoreBroadcastTimer = 0;

  // Components
  late final Player _player;
  late final Hud _hud;
  late final LaneWorld _laneWorld;
  late final SpeedWarpFx _speedWarp;
  final List<Obstacle> _obstacles = [];
  final List<Patch> _patches = [];
  final _rng = Random();

  // Reusable vignette paints
  final Paint _crashFlashPaint = Paint();
  final Paint _crashVignettePaint = Paint();
  Rect? _lastVignetteRect;

  // Screen shake & crash flash
  double _screenShake = 0;
  double _crashFlash = 0;

  // Swipe gesture accumulator
  Vector2 _swipeDelta = Vector2.zero();
  static const double _swipeThreshold = 24.0;

  // Track cleared obstacles to award leap/slide bonuses once
  final Set<Obstacle> _clearedObstacles = {};

  @override
  Color backgroundColor() => const Color(GameConfig.colorBg);

  @override
  Future<void> onLoad() async {
    GameConfig.updateDimensions(size.x, size.y);
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    highScore = await HighScoreService.load();

    await world.add(Starfield());
    _laneWorld = LaneWorld();
    await world.add(_laneWorld);

    _speedWarp = SpeedWarpFx();
    await world.add(_speedWarp);

    _player = Player(currentLane: 1, skin: skin);
    await world.add(_player);

    _hud = Hud(playerTag: playerTag);
    _hud.highScore = highScore;
    await world.add(_hud);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    GameConfig.updateDimensions(size.x, size.y);
    _lastVignetteRect = null;
  }

  @override
  void update(double dt) {
    if (_isOver) return;

    // Clamp delta time to prevent physics tunneling or large spikes
    final safeDt = dt.clamp(0.001, 0.033);
    super.update(safeDt);

    _elapsed += safeDt;
    _hud.elapsed = _elapsed;
    _hud.totalPatches = totalPatches;
    _laneWorld.totalPatches = totalPatches;
    _laneWorld.isInvincible = _player.isInvincible;
    _speedWarp.isHotReload = _player.isInvincible;
    _speedWarp.speedMultiplier =
        currentLevel.speedMultiplier * (_player.isInvincible ? 1.65 : 1.0);

    // Survival points (boosted ticking and double points during invincibility)
    _timePointTimer += safeDt * (_player.isInvincible ? 2.0 : 1.0);
    if (_timePointTimer >= GameConfig.timePointInterval) {
      _timePointTimer -= GameConfig.timePointInterval;
      score += GameConfig.timePoints * (_player.isInvincible ? 2 : 1);
      _hud.score = score;
    }

    // Broadcast score updates for lobby / multiplayer
    _scoreBroadcastTimer += safeDt;
    if (_scoreBroadcastTimer >= 0.15) {
      _scoreBroadcastTimer = 0;
      onScoreUpdate?.call(score, totalPatches, currentLevel, !_isOver);
    }

    // Spawn obstacles (faster spawn to provide smash targets during invincibility)
    _obstacleTimer += safeDt * (_player.isInvincible ? 1.5 : 1.0);
    final obstInterval = GameConfig.obstacleInterval(totalPatches);
    if (_obstacleTimer >= obstInterval) {
      _obstacleTimer = 0;
      _spawnObstacles();
    }

    // Spawn patches (boosted patch flow during invincibility)
    _patchTimer += safeDt * (_player.isInvincible ? 1.65 : 1.0);
    final patchInterval = GameConfig.patchInterval(totalPatches);
    if (_patchTimer >= patchInterval) {
      _patchTimer = 0;
      _spawnPatch();
    }

    // Hot Reload Magnetic Pull on Collectibles
    if (_player.isInvincible) {
      for (int i = 0; i < _patches.length; i++) {
        final p = _patches[i];
        if (!p.isCollected && p.depth > 0.10) {
          p.attractTowards(_player.currentLane, safeDt);
        }
      }
    }

    // Zero-allocation backwards loop for obstacles
    for (int i = _obstacles.length - 1; i >= 0; i--) {
      final o = _obstacles[i];
      o.totalPatches = totalPatches;
      o.isInvincible = _player.isInvincible;
      if (o.isPastPlayer) {
        _clearedObstacles.remove(o);
        _obstacles.removeAt(i);
        world.remove(o);
        continue;
      }

      if (_checkObstacleInteraction(o)) {
        return;
      }
    }

    // Zero-allocation backwards loop for patches
    for (int i = _patches.length - 1; i >= 0; i--) {
      final p = _patches[i];
      p.totalPatches = totalPatches;
      p.isInvincible = _player.isInvincible;
      if (p.isDone || p.isPastPlayer) {
        _patches.removeAt(i);
        world.remove(p);
        continue;
      }

      if (!p.isCollected && _checkPatchCollision(p)) {
        p.collect();
        _onPatchCollected(p);
      }
    }

    // Screen shake
    if (_screenShake > 0) {
      _screenShake = (_screenShake - safeDt * 3.5).clamp(0, 10);
      final shakeX = (_rng.nextDouble() - 0.5) * _screenShake * 12;
      final shakeY = (_rng.nextDouble() - 0.5) * _screenShake * 12;
      camera.viewfinder.position = Vector2(shakeX, shakeY);
    } else {
      camera.viewfinder.position = Vector2.zero();
    }

    // Crash flash fade
    if (_crashFlash > 0) {
      _crashFlash = (_crashFlash - safeDt * 2.5).clamp(0, 1);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fullscreen Red Danger Flash & Vignette (zero per-frame allocations)
    if (_crashFlash > 0) {
      final fullRect = Rect.fromLTWH(0, 0, size.x, size.y);
      _crashFlashPaint.color =
          const Color(0xFFFF2A4B).withValues(alpha: _crashFlash * 0.45);
      canvas.drawRect(fullRect, _crashFlashPaint);

      if (_lastVignetteRect != fullRect) {
        _lastVignetteRect = fullRect;
        _crashVignettePaint.shader = const RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            Color(0x00000000),
            Color(0xFFFF1744),
          ],
        ).createShader(fullRect);
      }
      _crashVignettePaint.color =
          const Color(0xFFFFFFFF).withValues(alpha: _crashFlash * 0.75);
      canvas.drawRect(fullRect, _crashVignettePaint);
    }
  }

  void _spawnObstacles() {
    final doubleChance = GameConfig.doubleObstacleChance(totalPatches);
    final spawnDouble = _rng.nextDouble() < doubleChance;

    final firstLane = _rng.nextInt(GameConfig.laneCount);
    final firstType =
        ObstacleType.values[_rng.nextInt(ObstacleType.values.length)];
    final obs1 = Obstacle(lane: firstLane, type: firstType, rng: _rng);
    obs1.totalPatches = totalPatches;
    _obstacles.add(obs1);
    world.add(obs1);

    if (spawnDouble) {
      // Pick a second distinct lane - guarantees exactly 1 open lane to dodge into!
      final otherLanes = [0, 1, 2]..remove(firstLane);
      final secondLane = otherLanes[_rng.nextInt(otherLanes.length)];
      final secondType =
          ObstacleType.values[_rng.nextInt(ObstacleType.values.length)];

      final obs2 = Obstacle(lane: secondLane, type: secondType, rng: _rng);
      obs2.totalPatches = totalPatches;
      _obstacles.add(obs2);
      world.add(obs2);
    }
  }

  void _spawnPatch() {
    final lane = _rng.nextInt(GameConfig.laneCount);
    // 16% chance of spawning a glowing Hot Reload Booster patch
    final isBooster = _rng.nextDouble() < 0.16;

    final patch = Patch(
      lane: lane,
      rng: _rng,
      isHotReloadBooster: isBooster,
      onMissed: (pos) => _onPatchMissed(pos),
    );
    patch.totalPatches = totalPatches;
    _patches.add(patch);
    world.add(patch);
  }

  bool _checkObstacleInteraction(Obstacle o) {
    if (o.depth < 0.86 || o.depth > 1.03) return false;
    if (o.lane != _player.currentLane) return false;

    final playerPos = _player.worldPosition;
    final obsPos = o.worldPosition;
    final dx = (playerPos.dx - obsPos.dx).abs();
    final dy = (playerPos.dy - obsPos.dy).abs();

    final isHorizontallyColliding = dx < GameConfig.collisionRadius &&
        dy < GameConfig.collisionRadius * 1.5;
    if (!isHorizontallyColliding) return false;

    // 1. Hot Reload Invincible Forcefield: Smash through obstacle!
    if (_player.isInvincible) {
      _smashObstacle(o);
      return false;
    }

    // 2. Jumping clearance over low obstacles (Worm Bug, Merge Barricade)
    if (o.isJumpable && _player.isJumping) {
      if (!_clearedObstacles.contains(o)) {
        _clearedObstacles.add(o);
        score += 150;
        _hud.score = score;
        AudioService.playStomp();
        _addFloatingText(
          '🦘 LEAP! +150',
          o.worldPosition,
          const Color(0xFF00E5FF),
          size: 17,
        );
      }
      return false;
    }

    // 3. Sliding clearance under high obstacles (Overhead Review Laser Gate)
    if (o.isSlideable && _player.isSliding) {
      if (!_clearedObstacles.contains(o)) {
        _clearedObstacles.add(o);
        score += 150;
        _hud.score = score;
        AudioService.playSlide();
        _addFloatingText(
          '⚡ SLIDE! +150',
          o.worldPosition,
          const Color(0xFFFFD700),
          size: 17,
        );
      }
      return false;
    }

    // Crashed!
    _triggerCrash();
    return true;
  }

  void _smashObstacle(Obstacle o) {
    o.isDead = true;
    _clearedObstacles.remove(o);
    _obstacles.remove(o);
    world.remove(o);

    score += 300;
    _hud.score = score;
    AudioService.playStomp();
    _screenShake = 0.8;

    _addFloatingText(
      '💥 SQUASHED! +300',
      o.worldPosition,
      const Color(0xFF00FF88),
      size: 18,
    );
  }

  bool _checkPatchCollision(Patch p) {
    if (p.depth < 0.82 || p.depth > 1.03) return false;
    if (p.lane != _player.currentLane) return false;
    final playerPos = _player.worldPosition;
    final patchPos = p.worldPosition;
    final dx = (playerPos.dx - patchPos.dx).abs();
    final dy = (playerPos.dy - patchPos.dy).abs();
    return dx < GameConfig.collisionRadius * 1.3 &&
        dy < GameConfig.collisionRadius * 1.8;
  }

  void _onPatchCollected(Patch p) {
    final pos = p.worldPosition;
    totalPatches++;
    _combo++;

    final isBoosted = _player.isInvincible;
    final regularPoints =
        isBoosted ? GameConfig.patchPoints * 2 : GameConfig.patchPoints;

    if (p.isHotReloadBooster) {
      _player
          .triggerHotReload(6.0); // 6 seconds of invincible Hot Reload power!
      _hud.triggerComboFlash();
      _screenShake = 0.5;
      score += 500;
      _addFloatingText(
        '🔥 HOT RELOAD! +500',
        pos,
        const Color(0xFFFF9100),
        size: 20,
      );
    } else {
      score += regularPoints;
      _addFloatingText(
        isBoosted ? '+$regularPoints ⚡2X PATCH!' : '+$regularPoints 🐤 PATCH!',
        pos,
        isBoosted ? const Color(0xFF00FFCC) : const Color(0xFFFFD700),
      );
    }

    if (_combo > 0 && _combo % GameConfig.comboThreshold == 0) {
      score += GameConfig.comboBonus;
      _hud.triggerComboFlash();
      AudioService.playCombo();
      _addFloatingText(
        'COMBO ×$_combo! +${GameConfig.comboBonus}',
        Offset(pos.dx, pos.dy - 30),
        const Color(GameConfig.colorAmber),
      );
    }

    final newLevel = GameConfig.levelFor(totalPatches);
    if (newLevel.level > currentLevel.level) {
      _triggerLevelUp(newLevel);
    }

    _hud.score = score;
    _hud.combo = _combo;
    _hud.totalPatches = totalPatches;
  }

  void _onPatchMissed(Offset pos) {
    // Penalty for missing a patch!
    score = max(0, score - GameConfig.missedPatchPenalty);
    _combo = 0; // reset streak
    _hud.score = score;
    _hud.combo = 0;
    _hud.triggerMissFlash();

    AudioService.playMiss();
    _addFloatingText(
      '-${GameConfig.missedPatchPenalty} 🐤 MISSED!',
      Offset(pos.dx, GameConfig.nearY - 20),
      const Color(0xFFFF2A4B),
      size: 18,
    );
  }

  void _triggerLevelUp(LevelConfig newLevel) {
    currentLevel = newLevel;
    score += GameConfig.levelUpBonus;
    _hud.score = score;
    _hud.triggerLevelUp(newLevel);

    AudioService.playLevelUp();
    _screenShake = 1.0;

    _addFloatingText(
      '${newLevel.emoji} ${newLevel.name} UNLOCKED! +${GameConfig.levelUpBonus}',
      Offset(GameConfig.designWidth / 2, 260),
      Color(newLevel.accentColor),
      size: 24,
    );

    for (final o in List.of(_obstacles)) {
      if (o.depth > 0.35) {
        _obstacles.remove(o);
        world.remove(o);
      }
    }
  }

  void _addFloatingText(
    String text,
    Offset pos,
    Color color, {
    double size = 16,
  }) {
    world.add(FloatingText(text, pos, color, size));
  }

  void _triggerCrash() {
    if (_isOver) return;
    _isOver = true;
    _crashFlash = 1.0;
    _screenShake = 1.5;
    AudioService.playCrash();

    // Broadcast immediate crash to lobby
    onScoreUpdate?.call(score, totalPatches, currentLevel, false);

    HighScoreService.save(score).then((_) async {
      highScore = await HighScoreService.load();
      await Future.delayed(const Duration(milliseconds: 650));
      if (!isMounted) return;
      onGameOver(score, totalPatches, currentLevel);
    });
  }

  // ── Input Handling (WASD, Arrows, Space, Touch, Swipe) ────────────────────

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_isOver) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      final allowLeft = (controlScheme == ControlScheme.both &&
              (key == LogicalKeyboardKey.arrowLeft ||
                  key == LogicalKeyboardKey.keyA)) ||
          (controlScheme == ControlScheme.wasd &&
              key == LogicalKeyboardKey.keyA) ||
          (controlScheme == ControlScheme.arrows &&
              key == LogicalKeyboardKey.arrowLeft);

      final allowRight = (controlScheme == ControlScheme.both &&
              (key == LogicalKeyboardKey.arrowRight ||
                  key == LogicalKeyboardKey.keyD)) ||
          (controlScheme == ControlScheme.wasd &&
              key == LogicalKeyboardKey.keyD) ||
          (controlScheme == ControlScheme.arrows &&
              key == LogicalKeyboardKey.arrowRight);

      final allowJump = (controlScheme == ControlScheme.both &&
              (key == LogicalKeyboardKey.arrowUp ||
                  key == LogicalKeyboardKey.keyW ||
                  key == LogicalKeyboardKey.space)) ||
          (controlScheme == ControlScheme.wasd &&
              (key == LogicalKeyboardKey.keyW ||
                  key == LogicalKeyboardKey.space)) ||
          (controlScheme == ControlScheme.arrows &&
              key == LogicalKeyboardKey.arrowUp);

      final allowSlide = (controlScheme == ControlScheme.both &&
              (key == LogicalKeyboardKey.arrowDown ||
                  key == LogicalKeyboardKey.keyS)) ||
          (controlScheme == ControlScheme.wasd &&
              key == LogicalKeyboardKey.keyS) ||
          (controlScheme == ControlScheme.arrows &&
              key == LogicalKeyboardKey.arrowDown);

      if (allowLeft) {
        _player.moveLeft();
        return KeyEventResult.handled;
      }
      if (allowRight) {
        _player.moveRight();
        return KeyEventResult.handled;
      }
      if (allowJump) {
        _player.jump();
        return KeyEventResult.handled;
      }
      if (allowSlide) {
        _player.slide();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ── Swipe Drag Gestures (Subway Surfers Style) ───────────────────────────

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _swipeDelta = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_isOver) return;
    _swipeDelta += event.canvasDelta;

    if (_swipeDelta.x < -_swipeThreshold) {
      _player.moveLeft();
      _swipeDelta = Vector2.zero();
    } else if (_swipeDelta.x > _swipeThreshold) {
      _player.moveRight();
      _swipeDelta = Vector2.zero();
    } else if (_swipeDelta.y < -_swipeThreshold) {
      _player.jump();
      _swipeDelta = Vector2.zero();
    } else if (_swipeDelta.y > _swipeThreshold) {
      _player.slide();
      _swipeDelta = Vector2.zero();
    }
  }

  void moveToLane(int lane) => _player.moveToLane(lane);
  void moveLeft() => _player.moveLeft();
  void moveRight() => _player.moveRight();

  void jump() => _player.jump();
  void slide() => _player.slide();
  int get currentLane => _player.currentLane;

  // ── Tap on Lane (Direct Lane Steering) ──────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (_isOver) return;
    final tapX = event.canvasPosition.x;

    // Directly click on the desired lane to move player there
    if (tapX < size.x * 0.36) {
      moveToLane(0);
    } else if (tapX > size.x * 0.64) {
      moveToLane(2);
    } else {
      moveToLane(1);
    }
  }
}
