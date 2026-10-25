import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/widgets/async_page.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/core/widgets/empty_state.dart';
import 'package:e_smart/core/widgets/product_card.dart';
import 'package:e_smart/features/products/data/product.dart';
import 'package:e_smart/features/products/logic/product_controller.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    return AsyncPage<CatalogPageData>(
      value: catalog,
      onRetry: () => ref.read(catalogProvider.notifier).refresh().then((failure) {
        if (failure != null) {
          ref.read(toastProvider.notifier).show(failureMessage(failure));
        }
      }),
      data: (page) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            final failure = await ref.read(catalogProvider.notifier).refresh();
            if (failure != null) {
              ref.read(toastProvider.notifier).show(failureMessage(failure));
            }
          },
          child: page.items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    EmptyState(
                      message: AppCopy.noProducts,
                      icon: Icons.spa_outlined,
                    ),
                  ],
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 280 && page.hasMore) {
                      ref.read(catalogProvider.notifier).loadMore().then((failure) {
                        if (failure != null) {
                          ref.read(toastProvider.notifier).show(failureMessage(failure));
                        }
                      });
                    }
                    return false;
                  },
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: PageScaffoldPadding.edge,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.gridGap,
                      crossAxisSpacing: AppSpacing.gridGap,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: page.items.length + (page.loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= page.items.length) {
                        return const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final product = page.items[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/products/${product.id}'),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
