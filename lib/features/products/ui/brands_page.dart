import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/async_page.dart';
import 'package:e_smart/core/widgets/empty_state.dart';
import 'package:e_smart/core/widgets/product_card.dart';
import 'package:e_smart/core/widgets/surface_card.dart';
import 'package:e_smart/features/products/data/product.dart';
import 'package:e_smart/features/products/logic/product_controller.dart';

/// Brands come from the `brand` string on products already loaded.
/// There is no brand-list endpoint, so nothing is invented.
class BrandsPage extends ConsumerWidget {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return AsyncPage<CatalogPageData>(
      value: catalog,
      onRetry: () => ref.read(catalogProvider.notifier).refresh(),
      data: (page) {
        final names = <String>[];
        for (final product in page.items) {
          if (product.brand.isNotEmpty && !names.contains(product.brand)) {
            names.add(product.brand);
          }
        }
        if (names.isEmpty) {
          return const EmptyState(message: AppCopy.noProducts);
        }
        return ListView.separated(
          padding: PageScaffoldPadding.edge,
          itemCount: names.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(AppCopy.brands, style: AppTextStyles.pageTitle);
            }
            final name = names[index - 1];
            return SurfaceCard(
              padding: EdgeInsets.zero,
              radius: AppRadius.productCard,
              onTap: () => context.push(
                '/brands/view?name=${Uri.encodeQueryComponent(name)}',
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(Icons.diamond_outlined, color: AppColors.goldDark),
                ),
                title: Text(name, style: AppTextStyles.productName),
                trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              ),
            );
          },
        );
      },
    );
  }
}

class BrandProductsPage extends ConsumerWidget {
  const BrandProductsPage({super.key, required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return AsyncPage<CatalogPageData>(
      value: catalog,
      onRetry: () => ref.read(catalogProvider.notifier).refresh(),
      data: (page) {
        final items = [
          for (final product in page.items)
            if (product.brand == brand) product,
        ];
        if (items.isEmpty) {
          return const EmptyState(message: AppCopy.noProducts);
        }
        return GridView.builder(
          padding: PageScaffoldPadding.edge,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.gridGap,
            crossAxisSpacing: AppSpacing.gridGap,
            childAspectRatio: 0.58,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];
            return ProductCard(
              product: product,
              onTap: () => context.push('/products/${product.id}'),
            );
          },
        );
      },
    );
  }
}
