import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/order.dart';
import 'package:plume/features/orders/orders_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class OrderConfirmedPage extends StatelessWidget {
  const OrderConfirmedPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final order = context.select<OrdersCubit, Order?>(
      (c) => c.state.byId(orderId),
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const _AnimatedCheck(),
                  const SizedBox(height: 32),
                  Entrance(
                    index: 6,
                    child: Text(
                      l10n.orderConfirmedTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (order != null)
                    Entrance(
                      index: 8,
                      child: Text(
                        l10n.orderConfirmedMessage(
                          order.id,
                          DateFormat.MMMMEEEEd(locale)
                              .format(order.estimatedDelivery),
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Entrance(
                    index: 10,
                    child: FilledButton.icon(
                      onPressed: () => context.go(Routes.order(orderId)),
                      icon: const Icon(Icons.route_rounded),
                      label: Text(l10n.trackOrder),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Entrance(
                    index: 11,
                    child: OutlinedButton(
                      onPressed: () => context.go(Routes.discover),
                      child: Text(l10n.continueShopping),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCheck extends StatefulWidget {
  const _AnimatedCheck();

  @override
  State<_AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<_AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) {
      if (Motion.reduced(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
    );
    return ScaleTransition(
      scale: circle,
      child: Container(
        width: 112,
        height: 112,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.violet,
        ),
        child: CustomPaint(
          painter: _CheckPainter(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.4, 1, curve: Motion.emphasized),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.67)
      ..lineTo(size.width * 0.73, size.height * 0.36);
    final metric = path.computeMetrics().first;
    final length = metric.length * math.max(0, progress.value);
    canvas.drawPath(
      metric.extractPath(0, length),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => false;
}
