import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/catalog_meta.dart';
import 'package:plume/l10n/l10n.dart';

/// Auto-advancing hero carousel with depth and parallax.
class CollectionCarousel extends StatefulWidget {
  const CollectionCarousel({required this.collections, super.key});

  final List<Collection> collections;

  @override
  State<CollectionCarousel> createState() => _CollectionCarouselState();
}

class _CollectionCarouselState extends State<CollectionCarousel> {
  final _controller = PageController(viewportFraction: 0.86);
  Timer? _timer;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _page = _controller.page!));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (!Motion.reduced(context)) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _advance());
    }
  }

  void _advance() {
    if (!_controller.hasClients || widget.collections.isEmpty) return;
    final next = (_page.round() + 1) % widget.collections.length;
    _controller.animateToPage(
      next,
      duration: Motion.slow,
      curve: Motion.standard,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections = widget.collections;
    return Column(
      children: [
        SizedBox(
          height: 236,
          child: NotificationListener<ScrollStartNotification>(
            // Pause auto-advance while the user is swiping.
            onNotification: (notification) {
              if (notification.dragDetails != null) {
                _timer?.cancel();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final delta = (_page - index).clamp(-1.0, 1.0);
                return Transform.scale(
                  scale: 1 - delta.abs() * 0.08,
                  child: _CollectionCard(
                    collection: collections[index],
                    parallax: delta,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < collections.length; i++)
              AnimatedContainer(
                duration: Motion.of(context, Motion.medium),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _page.round() == i ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: _page.round() == i ? 0.85 : 0.2),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.parallax});

  final Collection collection;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Pressable(
        semanticLabel: collection.title,
        onTap: () => context.push(Routes.collection(collection.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AuroraBackground(colors: collection.colors),
              Positioned(
                right: -30 + parallax * 60,
                bottom: -30,
                child: Transform.rotate(
                  angle: -0.25 + parallax * 0.3,
                  child: Icon(
                    AppIcons.of(collection.icon),
                    size: 190,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        context.l10n.collectionLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      collection.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          context.l10n.shopNow,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
