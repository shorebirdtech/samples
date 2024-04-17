import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:super_dash_counter/game/game.dart';

class DashComponent extends PositionComponent
    with HasGameRef<SuperDashCounterGame> {
  DashComponent({
    super.position,
  }) : super(size: Vector2.all(16));

  static const walkSpeed = 40;
  static const gravityFactor = 120;
  static const jumpForce = 52.0;

  late final Sprite _idleSprite;
  late final Sprite _jumpingSprite;
  late final Sprite _fallingSprite;
  late final SpriteAnimation _runningAnimation;

  PositionComponent? _currentSprite;

  double _jump = 0;

  set jump(double value) {
    if (value == jumpForce && _jump != 0) {
      // Don't jump if already jumping.
      return;
    }

    if (_jump == 0 && value > 0) {
      _updateSprite(
        SpriteComponent(
          sprite: _jumpingSprite,
          size: size,
        ),
      );
    }

    if (_jump >= 0 && value <= 0) {
      _updateSprite(
        SpriteComponent(
          sprite: _fallingSprite,
          size: size,
        ),
      );
    }

    if (_jump <= 0 && value == 0) {
      _updateSprite(
        SpriteComponent(
          sprite: _idleSprite,
          size: size,
        ),
      );
    }

    _jump = value;
  }

  double get jump => _jump;

  int _lastDirection = 1;
  int? _direction;

  set direction(int? value) {
    if (value != null && value != _lastDirection) {
      _currentSprite?.flipHorizontallyAroundCenter();
      _lastDirection = value;
    }

    if (value != null && _direction == null) {
      _updateSprite(
        SpriteAnimationComponent(
          animation: _runningAnimation,
          size: size,
        ),
      );
    }

    if (value == null && _direction != null) {
      _updateSprite(
        SpriteComponent(
          sprite: _idleSprite,
          size: size,
        ),
      );
    }

    _direction = value;
  }

  int? get direction => _direction;

  void _updateSprite(PositionComponent newSprite) {
    if (_currentSprite != null) {
      newSprite.transform.setFrom(_currentSprite!.transform);
    }

    _currentSprite?.removeFromParent();
    add(_currentSprite = newSprite);
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    _idleSprite = await gameRef.loadSprite('dash_idle.png');
    _jumpingSprite = await gameRef.loadSprite('dash_jumping.png');
    _fallingSprite = await gameRef.loadSprite('dash_falling.png');
    _runningAnimation = await gameRef.loadSpriteAnimation(
      'dash_running.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2.all(16),
      ),
    );

    _updateSprite(
      SpriteComponent(
        sprite: _idleSprite,
        size: size,
      ),
    );

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    final jumping = jump != 0;

    if (jumping) {
      jump -= gravityFactor * dt;

      if (jump < 0) {
        position.y += gravityFactor * dt;
        if (position.y >= SuperDashCounterGame.groundLevel) {
          position.y = SuperDashCounterGame.groundLevel;
          jump = 0;
        }
      } else {
        position.y -= jump * dt;
      }
    } else {
      final currentDirection = direction;
      if (currentDirection != null) {
        final newPosition = position.x + walkSpeed * currentDirection * dt;
        final gameBounds = SuperDashCounterGame.gameResolution.x / 2;
        if (newPosition >= -gameBounds && newPosition <= gameBounds - 16) {
          position.x = newPosition;
        }
      }
    }
  }
}
