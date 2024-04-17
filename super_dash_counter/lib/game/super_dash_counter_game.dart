import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:super_dash_counter/game/game.dart';

class SuperDashCounterGame extends FlameGame with HasCollisionDetection {
  final counter = ValueNotifier<int>(0);

  static final gameResolution = Vector2(48, 64);
  static const groundLevel = 0.0;

  late final DashComponent _dash;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    camera = CameraComponent.withFixedResolution(
      width: gameResolution.x,
      height: gameResolution.y,
    );

    _dash = DashComponent(position: Vector2(32, 32));

    _dash.position = Vector2(-8, groundLevel);
    world.add(_dash);

    final groundSprite = await loadSprite('ground.png');
    world.add(
      SpriteComponent(
        sprite: groundSprite,
        position: Vector2(-gameResolution.x / 2, groundLevel + 16),
        size: Vector2(gameResolution.x, 32),
      ),
    );

    world.add(
      BlockComponent(
        addNumber: true,
        position: Vector2(-24, groundLevel - 32),
      ),
    );

    world.add(
      BlockComponent(
        addNumber: false,
        position: Vector2(8, groundLevel - 32),
      ),
    );
  }

  void jump() {
    _dash.jump = DashComponent.jumpForce;
  }

  void startMoving(int direction) {
    _dash.direction = direction;
  }

  void stopMoving(int direction) {
    if (_dash.direction == direction) {
      _dash.direction = null;
    }
  }
}
