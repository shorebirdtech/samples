/// Central configuration for Patch Rush game balance, Mario 3D mechanics, and Booth Battle.
library;

/// Defines a single stage / world in the game.
class LevelConfig {
  final int level;
  final String name;
  final String subtitle;
  final String emoji;

  /// Total cumulative patches collected needed to *enter* this level.
  final int patchThreshold;

  /// Total cumulative patches collected to complete this level (or null if max/endless).
  final int? nextThreshold;

  /// Overall speed multiplier at this level.
  final double speedMultiplier;

  /// Seconds between obstacle spawns.
  final double obstacleInterval;

  /// Seconds between patch spawns.
  final double patchInterval;

  /// Probability of 2 lanes having obstacles simultaneously (forcing jump or precision steer).
  final double doubleObstacleChance;

  /// Theme accent color (HUD badges, level-up banners, particle flares).
  final int accentColor;

  /// Road surface tint.
  final int roadColor;

  /// Road edge glow color.
  final int edgeColor;

  /// Horizon glow color.
  final int horizonColor;

  final String planQuota;

  const LevelConfig({
    required this.level,
    required this.name,
    required this.planQuota,
    required this.subtitle,
    required this.emoji,
    required this.patchThreshold,
    required this.nextThreshold,
    required this.speedMultiplier,
    required this.obstacleInterval,
    required this.patchInterval,
    required this.doubleObstacleChance,
    required this.accentColor,
    required this.roadColor,
    required this.edgeColor,
    required this.horizonColor,
  });

  /// How many patches needed in this level alone to reach the next level.
  int get patchesNeeded {
    if (nextThreshold == null) return 20; // max level loop
    return nextThreshold! - patchThreshold;
  }
}

class GameConfig {
  GameConfig._();

  // ── Canvas / viewport ─────────────────────────────────────────────────────
  static const double designWidth = 800;
  static const double designHeight = 600;

  // ── Lane layout ───────────────────────────────────────────────────────────
  static const int laneCount = 3;

  /// X-positions of lane centers at the NEAR edge (bottom of the road).
  static const List<double> nearLaneX = [190, 400, 610];

  /// X-positions of lane centers at the FAR edge (horizon/vanishing point).
  static const List<double> farLaneX = [345, 400, 455];

  /// Y-position of the horizon line.
  static const double horizonY = 210;

  /// Y-position of the near (player) edge.
  static const double nearY = 560;

  /// Vanishing point X.
  static const double vanishingX = 400;

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
      accentColor: 0xFF00D4FF, // Cyan
      roadColor: 0xFF0B1726,
      edgeColor: 0xFF00D4FF,
      horizonColor: 0xFF0088CC,
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
      accentColor: 0xFF00FF88, // Emerald Green
      roadColor: 0xFF081C1B,
      edgeColor: 0xFF00FF88,
      horizonColor: 0xFF00B050,
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
      accentColor: 0xFFFFB347, // Amber / Solar
      roadColor: 0xFF1C1408,
      edgeColor: 0xFFFFB347,
      horizonColor: 0xFFE67E22,
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
      accentColor: 0xFFA855F7, // Cosmic Violet
      roadColor: 0xFF120824,
      edgeColor: 0xFFA855F7,
      horizonColor: 0xFF6D28D9,
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

  // ── Colors ────────────────────────────────────────────────────────────────
  static const int colorBg = 0xFF050A14;
  static const int colorCyan = 0xFF00D4FF;
  static const int colorCoral = 0xFFFF5D73;
  static const int colorAmber = 0xFFFFB347;
  static const int colorPurple = 0xFF8B5CF6;
  static const int colorGreen = 0xFF00FF88;
  static const int colorGrid = 0xFF0D2035;
}
