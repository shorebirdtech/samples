import 'package:material_ui/material_ui.dart';
import 'package:plume/core/money.dart';
import 'package:plume/core/theme/motion.dart';

/// Counts smoothly from the previous amount to the new one.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(this.money, {this.style, this.prefix = '', super.key});

  final Money money;
  final TextStyle? style;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return TweenAnimationBuilder<double>(
      tween: Tween(end: money.cents.toDouble()),
      duration: Motion.of(context, Motion.slow),
      curve: Motion.emphasized,
      builder: (context, value, _) => Text(
        '$prefix${Money.cents(value.round()).format(locale)}',
        style: style,
        semanticsLabel: '$prefix${money.format(locale)}',
      ),
    );
  }
}
