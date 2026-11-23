import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/order.dart';
import 'package:plume/features/cart/domain/price_calculator.dart';
import 'package:plume/features/cart/view/order_summary_card.dart';
import 'package:plume/features/orders/orders_cubit.dart';
import 'package:plume/features/orders/view/order_status_chip.dart';
import 'package:plume/l10n/l10n.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({required this.orderId, super.key});

  final String orderId;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = context.select<OrdersCubit, Order?>(
      (c) => c.state.byId(widget.orderId),
    );
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.receipt_long_rounded,
          title: l10n.orderNotFound,
          message: l10n.ordersEmptyMessage,
          action: FilledButton(
            onPressed: () => context.go(Routes.discover),
            child: Text(l10n.backToShop),
          ),
        ),
      );
    }
    final status = order.statusAt(_now);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Overall progress through the journey, continuous rather than stepped.
    final elapsed = _now.difference(order.placedAt).inMilliseconds / 1000;
    final steps = OrderStatus.values.length - 1;
    final progress = (elapsed / (45 * steps)).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: Text(order.id)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: Motion.of(context, const Duration(seconds: 1)),
                builder: (context, value, _) => CustomPaint(
                  painter: _RoutePainter(
                    progress: value,
                    road: theme.colorScheme.surfaceContainer,
                    grid: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: Motion.of(context, Motion.medium),
                      child: Text(
                        status.label(l10n),
                        key: ValueKey(status),
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    Text(
                      l10n.estimatedDelivery(
                        DateFormat.MMMMEEEEd(locale)
                            .format(order.estimatedDelivery),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              OrderStatusChip(status: status),
            ],
          ),
          const SizedBox(height: 20),
          for (final step in OrderStatus.values)
            _TimelineStep(
              status: step,
              reached: step.index <= status.index,
              current: step == status,
              last: step == OrderStatus.values.last,
              time: order.placedAt.add(Duration(seconds: 45 * step.index)),
            ),
          const SizedBox(height: 12),
          Text(l10n.deliveringTo, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '${order.address.fullName}\n${order.address.singleLine}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(l10n.receipt, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 44,
                    child: ProductArt(
                      icon: line.icon,
                      color: Color(line.colorValue),
                      borderRadius: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${line.quantity} × ${line.name}')),
                  Text((line.unitPrice * line.quantity).format(locale)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          OrderSummaryCard(
            summary: OrderSummary(
              subtotal: order.subtotal,
              discount: order.discount,
              shipping: order.shipping,
              tax: order.tax,
              total: order.total,
              freeShippingRemaining: order.subtotal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.paidWith(order.cardLast4),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.reached,
    required this.current,
    required this.last,
    required this.time,
  });

  final OrderStatus status;
  final bool reached;
  final bool current;
  final bool last;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = reached ? status.color : theme.colorScheme.surfaceContainer;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _PulsingDot(color: color, pulsing: current, icon: status.icon),
                if (!last)
                  Expanded(
                    child: AnimatedContainer(
                      duration: Motion.of(context, Motion.slow),
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: reached && !current
                            ? status.color
                            : theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      status.label(context.l10n),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: reached
                            ? null
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                      ),
                    ),
                  ),
                  if (reached)
                    Text(
                      DateFormat.jm(
                        Localizations.localeOf(context).toLanguageTag(),
                      ).format(time),
                      style: theme.textTheme.bodySmall,
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

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.color,
    required this.pulsing,
    required this.icon,
  });

  final Color color;
  final bool pulsing;
  final IconData icon;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.pulsing && !Motion.reduced(context)) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: widget.pulsing
              ? [
                  BoxShadow(
                    color: widget.color.withValues(
                      alpha: 0.5 * (1 - _controller.value),
                    ),
                    spreadRadius: 14 * _controller.value,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
      child: Icon(widget.icon, size: 16, color: Colors.white),
    );
  }
}

/// A stylised map: a winding road from the warehouse to the customer, with
/// the courier's position at [progress].
class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.progress,
    required this.road,
    required this.grid,
  });

  final double progress;
  final Color road;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final start = Offset(size.width * 0.12, size.height * 0.72);
    final end = Offset(size.width * 0.88, size.height * 0.28);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.1,
        size.width * 0.6,
        size.height * 1.0,
        end.dx,
        end.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = road
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    final metric = path.computeMetrics().first;
    final travelled = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      travelled,
      Paint()
        ..shader = Palette.brandGradient.createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    _pin(canvas, start, Palette.iris, Icons.warehouse_rounded);
    _pin(canvas, end, Palette.success, Icons.home_rounded);

    final tangent = metric.getTangentForOffset(metric.length * progress);
    if (tangent != null) {
      canvas
        ..drawCircle(
          tangent.position,
          20,
          Paint()..color = Palette.violet.withValues(alpha: 0.25),
        )
        ..drawCircle(tangent.position, 13, Paint()..color = Palette.violet);
      _icon(
        canvas,
        tangent.position,
        Icons.local_shipping_rounded,
        14,
        flip: math.cos(tangent.angle) < 0,
      );
    }
  }

  void _pin(Canvas canvas, Offset at, Color color, IconData icon) {
    canvas
      ..drawCircle(at, 18, Paint()..color = color.withValues(alpha: 0.2))
      ..drawCircle(at, 12, Paint()..color = color);
    _icon(canvas, at, icon, 13);
  }

  void _icon(
    Canvas canvas,
    Offset at,
    IconData icon,
    double size, {
    bool flip = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas
      ..save()
      ..translate(at.dx, at.dy);
    if (flip) canvas.scale(-1, 1);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.road != road ||
      oldDelegate.grid != grid;
}
