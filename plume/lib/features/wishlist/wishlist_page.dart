import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/app/shell.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/product.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/features/discover/view/discover_page.dart';
import 'package:plume/features/wishlist/wishlist_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late Future<List<Product>> _products = context
      .read<CatalogRepository>()
      .products();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ids = context.watch<WishlistCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabWishlist)),
      body: FutureBuilder(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              onRetry: () => setState(
                () => _products = context.read<CatalogRepository>().products(),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final byId = {for (final p in snapshot.data!) p.id: p};
          final saved = [
            for (final id in ids)
              if (byId[id] != null) byId[id]!,
          ];
          if (saved.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_rounded,
              title: l10n.wishlistEmptyTitle,
              message: l10n.wishlistEmptyMessage,
              action: FilledButton(
                onPressed: () => context.go(Routes.discover),
                child: Text(l10n.startShopping),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  AppShell.contentInset(context),
                ),
                sliver: ProductGrid(products: saved, scope: 'wishlist'),
              ),
            ],
          );
        },
      ),
    );
  }
}
