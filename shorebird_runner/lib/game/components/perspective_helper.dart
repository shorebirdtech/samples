import 'dart:math';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Perspective helper: maps normalized depth t (0=horizon, 1=near player)
/// and lane index to a canvas position and scale factor.
class PerspectiveHelper {
  const PerspectiveHelper._();

  static Offset lanePosition(int lane, double t) {
    return fractionalLanePosition(lane.toDouble(), t);
  }

  static Offset fractionalLanePosition(double laneFrac, double t) {
    final tPow = pow(t, 1.6).toDouble();
    final clampedLane =
        laneFrac.clamp(0.0, (GameConfig.laneCount - 1).toDouble());
    final leftIdx = clampedLane.floor();
    final rightIdx = min(leftIdx + 1, GameConfig.laneCount - 1);
    final frac = clampedLane - leftIdx;

    final farX = GameConfig.farLaneX[leftIdx] +
        (GameConfig.farLaneX[rightIdx] - GameConfig.farLaneX[leftIdx]) * frac;
    final nearX = GameConfig.nearLaneX[leftIdx] +
        (GameConfig.nearLaneX[rightIdx] - GameConfig.nearLaneX[leftIdx]) * frac;
    final x = farX + (nearX - farX) * tPow;
    final y =
        GameConfig.horizonY + (GameConfig.nearY - GameConfig.horizonY) * tPow;
    return Offset(x, y);
  }

  static double scaleAtDepth(double t) {
    final tPow = pow(t, 1.6).toDouble();
    return GameConfig.horizonSizeMultiplier +
        (1.0 - GameConfig.horizonSizeMultiplier) * tPow;
  }
}
