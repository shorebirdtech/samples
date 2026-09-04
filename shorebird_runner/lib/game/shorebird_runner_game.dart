import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart' show Anchor;
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/hud.dart';
import 'package:shorebird_runner/game/components/lane_world.dart';
import 'package:shorebird_runner/game/components/obstacle.dart';
import 'package:shorebird_runner/game/components/patch.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/components/starfield.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';
import 'package:shorebird_runner/game/utils/high_score_service.dart';

enum ControlScheme {
  both, // Solo: A/D/W, Space, and Arrow keys all work
  wasd, // Player 1 in Booth Battle: A/D move, W/Space jump
  arrows, // Player 2 in Booth Battle: Left/Right move, Up jump
}

class ShorebirdRunnerGame extends FlameGame with KeyboardEvents, TapCallbacks {
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
  final List<Obstacle> _obstacles = [];
  final List<Patch> _patches = [];
  final List<_FloatingText> _floatingTexts = [];
  final _rng = Random();

  // Screen shake & crash flash
  double _screenShake = 0;
  double _crashFlash = 0;

  @override
  Color backgroundColor() => const Color(GameConfig.colorBg);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.visibleGameSize = Vector2(
      GameConfig.designWidth,
      GameConfig.designHeight,
    );
    camera.viewfinder.anchor = Anchor.topLeft;

    highScore = await HighScoreService.load();

    await world.add(Starfield());
    _laneWorld = LaneWorld();
    await world.add(_laneWorld);

    _player = Player(currentLane: 1, skin: skin);
    await world.add(_player);

    _hud = Hud(playerTag: playerTag);
    _hud.highScore = highScore;
    await world.add(_hud);
  }

  @override
  void update(double dt) {
    if (_isOver) return;
    super.update(dt);

    _elapsed += dt;
    _hud.elapsed = _elapsed;
    _hud.totalPatches = totalPatches;
    _laneWorld.totalPatches = totalPatches;

    // Survival points
    _timePointTimer += dt;
    if (_timePointTimer >= GameConfig.timePointInterval) {
      _timePointTimer -= GameConfig.timePointInterval;
      score += GameConfig.timePoints;
      _hud.score = score;
    }

    // Broadcast score updates for lobby / multiplayer
    _scoreBroadcastTimer += dt;
    if (_scoreBroadcastTimer >= 0.15) {
      _scoreBroadcastTimer = 0;
      onScoreUpdate?.call(score, totalPatches, currentLevel, !_isOver);
    }

    // Spawn obstacles (guaranteeing at least 1 open lane)
    _obstacleTimer += dt;
    final obstInterval = GameConfig.obstacleInterval(totalPatches);
    if (_obstacleTimer >= obstInterval) {
      _obstacleTimer = 0;
      _spawnObstacles();
    }

    // Spawn patches
    _patchTimer += dt;
    final patchInterval = GameConfig.patchInterval(totalPatches);
    if (_patchTimer >= patchInterval) {
      _patchTimer = 0;
      _spawnPatch();
    }

    // Update obstacles
    for (final o in List.of(_obstacles)) {
      o.totalPatches = totalPatches;
      if (o.isPastPlayer) {
        _obstacles.remove(o);
        world.remove(o);
        continue;
      }

      if (_checkObstacleInteraction(o)) {
        return;
      }
    }

    // Update patches
    for (final p in List.of(_patches)) {
      p.totalPatches = totalPatches;
      if (p.isDone || p.isPastPlayer) {
        _patches.remove(p);
        world.remove(p);
        continue;
      }

      if (!p.isCollected && _checkPatchCollision(p)) {
        p.collect();
        _onPatchCollected(p.worldPosition);
      }
    }

    // Update floating texts
    for (final ft in List.of(_floatingTexts)) {
      ft.update(dt);
      if (ft.isDone) {
        _floatingTexts.remove(ft);
      }
    }

    // Screen shake
    if (_screenShake > 0) {
      _screenShake = (_screenShake - dt * 3.5).clamp(0, 10);
      final shakeX = (_rng.nextDouble() - 0.5) * _screenShake * 12;
      final shakeY = (_rng.nextDouble() - 0.5) * _screenShake * 12;
      camera.viewfinder.position = Vector2(shakeX, shakeY);
    } else {
      camera.viewfinder.position = Vector2.zero();
    }

    // Crash flash
    if (_crashFlash > 0) {
      _crashFlash = (_crashFlash - dt * 2.5).clamp(0, 1);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final ft in _floatingTexts) {
      ft.render(canvas);
    }

    if (_crashFlash > 0) {
      canvas.drawRect(
        const Rect.fromLTWH(
            0, 0, GameConfig.designWidth, GameConfig.designHeight),
        Paint()
          ..color = const Color(GameConfig.colorCoral)
              .withValues(alpha: _crashFlash * 0.65),
      );
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
    final patch = Patch(
      lane: lane,
      rng: _rng,
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

    // Crashed!
    _triggerCrash();
    return true;
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

  void _onPatchCollected(Offset pos) {
    totalPatches++;
    _combo++;
    score += GameConfig.patchPoints;

    _addFloatingText(
        '+${GameConfig.patchPoints} 🐤 PATCH!', pos, const Color(0xFFFFD700));

    if (_combo > 0 && _combo % GameConfig.comboThreshold == 0) {
      score += GameConfig.comboBonus;
      _hud.triggerComboFlash();
      AudioService.playCombo();
      _addFloatingText('COMBO ×$_combo! +${GameConfig.comboBonus}',
          Offset(pos.dx, pos.dy - 30), const Color(GameConfig.colorAmber));
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
    _addFloatingText('-${GameConfig.missedPatchPenalty} 🐤 MISSED!',
        Offset(pos.dx, GameConfig.nearY - 20), const Color(0xFFFF2A4B),
        size: 18);
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
        const Offset(GameConfig.designWidth / 2, 260),
        Color(newLevel.accentColor),
        size: 24);

    for (final o in List.of(_obstacles)) {
      if (o.depth > 0.35) {
        _obstacles.remove(o);
        world.remove(o);
      }
    }
  }

  void _addFloatingText(String text, Offset pos, Color color,
      {double size = 16}) {
    _floatingTexts.add(_FloatingText(text, pos, color, size));
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
      onGameOver(score, totalPatches, currentLevel);
      overlays.add('game_over');
    });
  }

  // ── Input Handling (Pure Lane Dodging) ──────────────────────────────────────

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
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

      if (allowLeft) {
        _player.moveLeft();
        return KeyEventResult.handled;
      }
      if (allowRight) {
        _player.moveRight();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isOver) return;
    final tapX = event.canvasPosition.x;
    const midX = GameConfig.designWidth / 2;
    if (tapX < midX) {
      _player.moveLeft();
    } else {
      _player.moveRight();
    }
  }
}

class _FloatingText {
  final String text;
  Offset pos;
  final Color color;
  final double size;
  double life = 1.0;

  _FloatingText(this.text, this.pos, this.color, this.size);

  bool get isDone => life <= 0;

  void update(double dt) {
    pos = Offset(pos.dx, pos.dy - dt * 45);
    life = (life - dt * 1.5).clamp(0.0, 1.0);
  }

  void render(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: life),
          fontSize: size,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: const Color(0xFF000000).withValues(alpha: life * 0.8),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }
}
