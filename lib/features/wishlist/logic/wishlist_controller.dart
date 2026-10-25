import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/features/products/data/product.dart';
import 'package:e_smart/features/products/data/product_repository.dart';
import 'package:e_smart/features/products/logic/product_controller.dart';
import 'package:e_smart/features/wishlist/data/wishlist_repository.dart';

final wishlistIdsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  if (!ref.watch(tokenProvider).isAuthenticated) return const [];
  return ref.watch(wishlistRepositoryProvider).listIds();
});

/// Resolves wishlist ids against the loaded catalog; fetches missing by id.
final wishlistProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final ids = await ref.watch(wishlistIdsProvider.future);
  if (ids.isEmpty) return const [];
  final catalog = ref.watch(catalogProvider).valueOrNull?.items ?? const [];
  final byId = {for (final p in catalog) p.id: p};
  final repo = ref.read(productRepositoryProvider);
  final result = <Product>[];
  for (final id in ids) {
    final cached = byId[id];
    if (cached != null) {
      result.add(cached);
      continue;
    }
    try {
      result.add(await repo.getProduct(id));
    } catch (_) {
      // Skip ids that cannot be resolved — do not invent card fields.
    }
  }
  return result;
});
