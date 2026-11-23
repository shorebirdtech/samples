import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/data/sources/catalog_api.dart';
import 'package:plume/features/discover/view/discover_page.dart';
import 'package:plume/l10n/l10n.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({required this.collectionId, super.key});

  final String collectionId;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late Future<(Collection, List<Product>)> _future = _load();

  Future<(Collection, List<Product>)> _load() async {
    final catalog = context.read<CatalogRepository>();
    final collections = await catalog.collections();
    final collection = collections.firstWhere(
      (c) => c.id == widget.collectionId,
      orElse: () => throw const NetworkException('Unknown collection'),
    );
    final products = await catalog.products();
    return (
      collection,
      products.where((p) => collection.productIds.contains(p.id)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(onRetry: () => setState(() => _future = _load()));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (collection, products) = snapshot.data!;
          final theme = Theme.of(context);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                stretch: true,
                foregroundColor: Colors.white,
                backgroundColor: collection.colors[1],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 56,
                    bottom: 16,
                    end: 16,
                  ),
                  title: Text(
                    collection.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  background: AuroraBackground(
                    colors: collection.colors,
                    child: Align(
                      alignment: const Alignment(0.8, 0.2),
                      child: Icon(
                        AppIcons.of(collection.icon),
                        size: 160,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    '${collection.subtitle} · '
                    '${context.l10n.itemCount(products.length)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                sliver: ProductGrid(products: products, scope: 'collection'),
              ),
            ],
          );
        },
      ),
    );
  }
}
