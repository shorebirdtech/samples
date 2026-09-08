import 'dart:math';

class StarData {
  final double x, y, speed, size, twinkle, twinkleSpeed, phase, brightness;
  final bool isGolden;

  StarData(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        speed = 0.3 + rng.nextDouble() * 1.5,
        size = 0.4 + rng.nextDouble() * 1.8,
        twinkle = rng.nextDouble(),
        twinkleSpeed = 0.5 + rng.nextDouble() * 3,
        phase = rng.nextDouble() * pi * 2,
        brightness = 0.4 + rng.nextDouble() * 0.6,
        isGolden = rng.nextDouble() < 0.08;
}
