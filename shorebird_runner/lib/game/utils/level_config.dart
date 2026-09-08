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
