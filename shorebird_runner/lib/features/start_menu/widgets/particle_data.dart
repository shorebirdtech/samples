import 'dart:math';

class ParticleData {
  final double startX, startY, speed, size, wobble;

  ParticleData(Random rng, int i)
      : startX = rng.nextDouble(),
        startY = rng.nextDouble(),
        speed = 0.04 + rng.nextDouble() * 0.08,
        size = 1.5 + rng.nextDouble() * 3.0,
        wobble = 0.3 + rng.nextDouble() * 0.7;
}
