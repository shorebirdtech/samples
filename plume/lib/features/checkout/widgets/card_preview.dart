import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/data/models/checkout.dart';

/// A live preview of the payment card that flips to show the CVV.
class CardPreview extends StatelessWidget {
  const CardPreview({
    required this.card,
    required this.cvv,
    required this.showBack,
    super.key,
  });

  final PaymentCard card;
  final String cvv;
  final bool showBack;

  static const Map<CardBrand, List<Color>> _gradients = {
    CardBrand.visa: [Color(0xFF1A1F71), Color(0xFF4F46E5)],
    CardBrand.mastercard: [Color(0xFF111827), Color(0xFFEB001B)],
    CardBrand.amex: [Color(0xFF0E7490), Color(0xFF2DD4BF)],
    CardBrand.unknown: [Color(0xFF1F2937), Color(0xFF7C5CFF)],
  };

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: showBack ? 1 : 0),
      duration: Motion.of(context, Motion.slow),
      curve: Motion.standard,
      builder: (context, value, _) {
        final angle = value * math.pi;
        final back = value > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: back
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: _face(context, back: true),
                )
              : _face(context, back: false),
        );
      },
    );
  }

  Widget _face(BuildContext context, {required bool back}) {
    final brand = card.brand;
    final textTheme = Theme.of(context).textTheme;
    final digits = card.digits.padRight(16, '•');
    final groups = [for (var i = 0; i < 16; i += 4) digits.substring(i, i + 4)]
        .join('  ');
    return AspectRatio(
      aspectRatio: 1.586,
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.medium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: _gradients[brand]!,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: back
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 28),
                  Container(height: 44, color: Colors.black87),
                  const SizedBox(height: 18),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    color: Colors.white,
                    child: Text(
                      cvv.isEmpty ? '•••' : cvv,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: Motion.of(context, Motion.medium),
                          child: Text(
                            brand.label.toUpperCase(),
                            key: ValueKey(brand),
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FittedBox(
                      child: Text(
                        groups,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card.holder.isEmpty
                                ? 'YOUR NAME'
                                : card.holder.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Text(
                          card.expiry.isEmpty ? 'MM/YY' : card.expiry,
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
