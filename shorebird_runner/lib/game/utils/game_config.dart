import 'dart:math';
import 'package:shorebird_runner/game/utils/level_config.dart';

/// Central configuration for Patch Rush game balance, Mario 3D mechanics, and Booth Battle.
class GameConfig {
  GameConfig._();

  // ── Canvas / viewport (dynamically updated to fill 100% of screen) ─────────
  static double designWidth = 800;
  static double designHeight = 600;

  // ── Lane layout ───────────────────────────────────────────────────────────
  static const int laneCount = 3;

  /// X-positions of lane centers at the NEAR edge (bottom of the road).
  static List<double> nearLaneX = [190, 400, 610];

  /// X-positions of lane centers at the FAR edge (horizon/vanishing point).
  static List<double> farLaneX = [345, 400, 455];

  /// Y-position of the horizon line.
  static double horizonY = 210;

  /// Y-position of the near (player) edge.
  static double nearY = 560;

  /// Vanishing point X.
  static double vanishingX = 400;

  /// Dynamically update viewport and lane layout for full-screen edge-to-edge rendering.
  static void updateDimensions(double width, double height) {
    if (width <= 0 || height <= 0) return;
    designWidth = width;
    designHeight = height;
    vanishingX = width / 2;

    final isPortrait = height > width;
    if (isPortrait) {
      horizonY = height * 0.28;
      nearY = height * 0.84;
      final roadWidth = width * 0.78;
      final laneSpacing = roadWidth / 2;
      nearLaneX = [
        vanishingX - laneSpacing,
        vanishingX,
        vanishingX + laneSpacing
      ];
      final farSpread = laneSpacing * 0.18;
      farLaneX = [vanishingX - farSpread, vanishingX, vanishingX + farSpread];
    } else {
      horizonY = height * 0.36;
      nearY = height * 0.88;
      final roadWidth = min(width * 0.65, height * 0.95);
      final laneSpacing = roadWidth / 2;
      nearLaneX = [
        vanishingX - laneSpacing,
        vanishingX,
        vanishingX + laneSpacing
      ];
      final farSpread = laneSpacing * 0.20;
      farLaneX = [vanishingX - farSpread, vanishingX, vanishingX + farSpread];
    }
  }

  // ── Penalty Rules (High Difficulty) ────────────────────────────────────────
  static const int missedPatchPenalty =
      15; // deducted if patch passes player uncollected

  // ── Shorebird Plans Stage Progression ──────────────────────────────────────
  static const List<LevelConfig> levels = [
    LevelConfig(
      level: 1,
      name: 'HOBBY',
      planQuota: '5,000 Patches',
      subtitle: 'Hobby Tier · 5,000 Patches',
      emoji: '🐣',
      patchThreshold: 0,
      nextThreshold: 8,
      speedMultiplier: 1.20,
      obstacleInterval: 1.75,
      patchInterval: 1.45,
      doubleObstacleChance: 0.15,
      accentColor: 0xFFFFC107, // Shorebird Gold — Hobby
      roadColor: 0xFF0B1118,
      edgeColor: 0xFFFFC107,
      horizonColor: 0xFFFF8F00,
    ),
    LevelConfig(
      level: 2,
      name: 'PRO',
      planQuota: '50K Patches',
      subtitle: 'Pro Tier · 50K Patches',
      emoji: '⚡',
      patchThreshold: 8,
      nextThreshold: 20,
      speedMultiplier: 1.65,
      obstacleInterval: 1.35,
      patchInterval: 1.20,
      doubleObstacleChance: 0.35,
      accentColor: 0xFF00BCD4, // Electric Cyan — Pro
      roadColor: 0xFF071318,
      edgeColor: 0xFF00BCD4,
      horizonColor: 0xFF0097A7,
    ),
    LevelConfig(
      level: 3,
      name: 'BUSINESS',
      planQuota: '1,000,000 Patches',
      subtitle: 'Business Tier · 1M Patches',
      emoji: '💼',
      patchThreshold: 20,
      nextThreshold: 36,
      speedMultiplier: 2.25,
      obstacleInterval: 1.00,
      patchInterval: 1.05,
      doubleObstacleChance: 0.50,
      accentColor: 0xFF4CAF50, // Shorebird Green — Business
      roadColor: 0xFF071410,
      edgeColor: 0xFF4CAF50,
      horizonColor: 0xFF2E7D32,
    ),
    LevelConfig(
      level: 4,
      name: 'ENTERPRISE',
      planQuota: 'Custom Patches',
      subtitle: 'Enterprise Tier · Custom Patches',
      emoji: '👑',
      patchThreshold: 36,
      nextThreshold: null,
      speedMultiplier: 3.00,
      obstacleInterval: 0.72,
      patchInterval: 0.85,
      doubleObstacleChance: 0.70,
      accentColor: 0xFF9C27B0, // Royal Violet — Enterprise
      roadColor: 0xFF0E0718,
      edgeColor: 0xFF9C27B0,
      horizonColor: 0xFF6A1B9A,
    ),
  ];

  /// Returns current [LevelConfig] for cumulative patch count.
  static LevelConfig levelFor(int patches) {
    LevelConfig current = levels.first;
    for (final l in levels) {
      if (patches >= l.patchThreshold) current = l;
    }
    return current;
  }

  /// Returns next level, or null if at max stage.
  static LevelConfig? nextLevel(int patches) {
    final cur = levelFor(patches);
    final idx = levels.indexOf(cur);
    if (idx + 1 < levels.length) return levels[idx + 1];
    return null;
  }

  /// Progress fraction (0.0 to 1.0) towards next level.
  static double levelProgressFraction(int patches) {
    final cur = levelFor(patches);
    if (cur.nextThreshold == null) return 1.0;
    final intoCurrent = patches - cur.patchThreshold;
    final needed = cur.nextThreshold! - cur.patchThreshold;
    return (intoCurrent / needed).clamp(0.0, 1.0);
  }

  /// Cumulative patches within the current level.
  static int patchesInCurrentLevel(int patches) {
    final cur = levelFor(patches);
    return patches - cur.patchThreshold;
  }

  // ── Dynamic parameters ─────────────────────────────────────────────────────
  static double scrollSpeed(int patches) {
    const base = 0.65;
    return base * levelFor(patches).speedMultiplier;
  }

  static double obstacleInterval(int patches) {
    return levelFor(patches).obstacleInterval;
  }

  static double patchInterval(int patches) {
    return levelFor(patches).patchInterval;
  }

  static double doubleObstacleChance(int patches) {
    return levelFor(patches).doubleObstacleChance;
  }

  // ── 3D Object sizes and scaling ───────────────────────────────────────────
  static const double playerNearSize = 54;
  static const double obstacleNearSize = 62;
  static const double patchNearSize = 42;
  static const double horizonSizeMultiplier = 0.10;

  // ── Player ────────────────────────────────────────────────────────────────
  static const double playerLaneY = 515;
  static const double laneChangeDuration = 0.14;

  // ── Collision ─────────────────────────────────────────────────────────────
  static const double collisionRadius = 28;

  // ── Scoring ───────────────────────────────────────────────────────────────
  static const int patchPoints = 25;
  static const int levelUpBonus = 200;
  static const int comboBonus = 50;
  static const int comboThreshold = 4;
  static const double timePointInterval = 0.5;
  static const int timePoints = 2;

  // ── Shorebird Brand Colors ────────────────────────────────────────────────
  static const int colorBg = 0xFF0C0D10; // Deep black-navy
  static const int colorGold = 0xFFFFC107; // Shorebird primary gold
  static const int colorAmber = 0xFFFF8F00; // Shorebird amber
  static const int colorCyan = 0xFF00BCD4; // Pro tier electric cyan
  static const int colorGreen = 0xFF4CAF50; // Business tier green
  static const int colorPurple = 0xFF9C27B0; // Enterprise violet
  static const int colorCoral = 0xFFFF5252; // Error/danger red
  static const int colorGrid = 0xFF111520;
}
