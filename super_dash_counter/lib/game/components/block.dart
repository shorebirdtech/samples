import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:super_dash_counter/game/game.dart';

class BlockComponent extends SpriteComponent
    with HasGameRef<SuperDashCounterGame>, CollisionCallbacks {
  BlockComponent({
    required this.addNumber,
    super.position,
  }) : super(size: Vector2.all(16));

  final bool addNumber;
  bool _animating = false;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite(
      addNumber ? 'plus_block.png' : 'minus_block.png',
    );

    add(
      RectangleHitbox.relative(
        Vector2.all(.8),
        parentSize: size,
      ),
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (_animating) {
      return;
    }

    if (other is DashComponent) {
      gameRef.counter.value += addNumber ? 1 : -1;
    }

    _animating = true;
    add(
      SequenceEffect([
        MoveEffect.by(
          Vector2(0, -4),
          CurvedEffectController(
            .08,
            Curves.easeIn,
          ),
        ),
        MoveEffect.by(
          Vector2(0, 4),
          CurvedEffectController(
            .08,
            Curves.easeOut,
          ),
        ),
      ], onComplete: () {
        _animating = false;
      }),
    );
  }
}
