import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/media_url.dart';
import 'package:e_smart/core/format/minor_price.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/app_buttons.dart';
import 'package:e_smart/core/widgets/async_page.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/core/widgets/surface_card.dart';
import 'package:e_smart/features/cart/logic/cart_controller.dart';
import 'package:e_smart/features/products/data/product.dart';
import 'package:e_smart/features/products/logic/product_controller.dart';
import 'package:e_smart/features/reviews/data/review.dart';
import 'package:e_smart/features/reviews/logic/review_controller.dart';
import 'package:e_smart/features/reviews/data/review_repository.dart';
import 'package:e_smart/features/wishlist/data/wishlist_repository.dart';

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailsProvider(productId));
    return AsyncPage<Product>(
      value: product,
      onRetry: () async {
        ref.invalidate(productDetailsProvider(productId));
      },
      data: (item) => _Details(product: item),
    );
  }
}

class _Details extends ConsumerStatefulWidget {
  const _Details({required this.product});

  final Product product;

  @override
  ConsumerState<_Details> createState() => _DetailsState();
}

class _DetailsState extends ConsumerState<_Details> {
  var _quantity = 1;
  var _adding = false;
  var _saving = false;
  var _rating = 5;
  var _submittingReview = false;
  final _reviewText = TextEditingController();
  final _displayName = TextEditingController();

  @override
  void dispose() {
    _reviewText.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    if (_adding || !widget.product.inStock) return;
    final stock = widget.product.stockQuantity;
    if (stock < 1) return;
    final orderQuantity = _quantity.clamp(1, stock).toInt();
    setState(() => _adding = true);
    try {
      ref.read(cartProvider.notifier).add(
        productId: widget.product.id,
        name: widget.product.name,
        imageUrl: widget.product.imageUrl,
        priceMinor: widget.product.priceMinor,
        currency: widget.product.currency,
        quantity: orderQuantity,
      );
      ref.read(toastProvider.notifier).show(AppCopy.addToCart);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _addToWishlist() async {
    if (_saving) return;
    if (!ref.read(tokenProvider).isAuthenticated) {
      context.push('/login?from=${Uri.encodeComponent('/products/${widget.product.id}')}');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(wishlistRepositoryProvider).add(widget.product.id);
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitReview() async {
    if (_submittingReview) return;
    final text = _reviewText.text.trim();
    final name = _displayName.text.trim();
    if (text.length > 2000 || name.length > 80) return;
    setState(() => _submittingReview = true);
    try {
      await ref.read(reviewRepositoryProvider).createReview(
        productId: widget.product.id,
        rating: _rating,
        text: text,
        displayName: name,
      );
      _reviewText.clear();
      _displayName.clear();
      ref.read(toastProvider.notifier).show(AppCopy.reviewReceived);
      await ref.read(reviewListProvider(widget.product.id).notifier).refresh();
    } on ConflictFailure {
      ref.read(toastProvider.notifier).show(AppCopy.reviewConflict);
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final signedIn = ref.watch(tokenProvider).isAuthenticated;
    final maxQuantity = product.stockQuantity < 1 ? 1 : product.stockQuantity;
    final quantity = _quantity.clamp(1, maxQuantity);
    return ListView(
      padding: PageScaffoldPadding.edge,
      children: [
        _Gallery(urls: product.gallery),
        const SizedBox(height: AppSpacing.md),
        Text(product.name, style: AppTextStyles.pageTitle),
        if (product.brand.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(product.brand, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        ],
        const SizedBox(height: AppSpacing.sm),
        MinorPriceText(
          minor: product.priceMinor,
          currency: product.currency,
          style: AppTextStyles.priceLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${AppCopy.stock}: ${product.stockQuantity}',
          textDirection: TextDirection.ltr,
          style: AppTextStyles.caption.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.md),
        _QuantityStepper(
          quantity: quantity,
          canDecrease: quantity > 1,
          canIncrease: product.inStock && quantity < product.stockQuantity,
          onDecrease: () => setState(() => _quantity = quantity - 1),
          onIncrease: () => setState(() => _quantity = quantity + 1),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPrimaryButton(
          label: AppCopy.addToCart,
          loading: _adding,
          onPressed: product.inStock ? _addToCart : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppSecondaryButton(
          label: AppCopy.addToWishlist,
          loading: _saving,
          onPressed: _addToWishlist,
        ),
        if (product.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(AppCopy.description, style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(product.description, style: AppTextStyles.body),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(AppCopy.reviews, style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        _Reviews(productId: product.id),
        if (signedIn) ...[
          const SizedBox(height: AppSpacing.lg),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppCopy.yourRating, style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    for (var star = 1; star <= 5; star++)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _rating = star),
                        icon: Icon(
                          star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: AppColors.gold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _displayName,
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: AppCopy.displayName),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _reviewText,
                  maxLength: 2000,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: AppCopy.reviewText),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: AppCopy.submitReview,
                  loading: _submittingReview,
                  onPressed: _submitReview,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: canDecrease ? onDecrease : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '$quantity',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.price,
              ),
            ),
            IconButton(
              onPressed: canIncrease ? onIncrease : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: AspectRatio(
        aspectRatio: 1,
        child: urls.isEmpty
            ? const ColoredBox(color: AppColors.pageBackground)
            : PageView.builder(
                itemCount: urls.length,
                itemBuilder: (context, index) {
                  final resolved = resolveMediaUrl(urls[index]);
                  return ColoredBox(
                    color: AppColors.pageBackground,
                    child: resolved == null
                        ? const SizedBox.expand()
                        : CachedNetworkImage(
                            imageUrl: resolved,
                            fit: BoxFit.contain,
                            placeholder: (_, _) =>
                                const ColoredBox(color: AppColors.pageBackground),
                            errorWidget: (_, _, _) =>
                                const ColoredBox(color: AppColors.pageBackground),
                          ),
                  );
                },
              ),
      ),
    );
  }
}

class _Reviews extends ConsumerWidget {
  const _Reviews({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(reviewListProvider(productId));
    return reviews.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
          ),
        ),
      ),
      error: (error, _) => LoadFailure(
        message: failureMessage(error),
        onRetry: () async => ref.invalidate(reviewListProvider(productId)),
      ),
      data: (page) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (page.items.isEmpty)
            Text(AppCopy.noRating, style: AppTextStyles.caption)
          else
            for (final review in page.items) ...[
              _ReviewTile(review: review),
              const SizedBox(height: AppSpacing.sm),
            ],
          if (page.hasMore)
            TextButton(
              onPressed: page.loadingMore
                  ? null
                  : () async {
                      final failure = await ref
                          .read(reviewListProvider(productId).notifier)
                          .loadMore();
                      if (failure != null) {
                        ref.read(toastProvider.notifier).show(failureMessage(failure));
                      }
                    },
              child: page.loadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(AppCopy.more),
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      radius: AppRadius.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var index = 0; index < 5; index++)
                Icon(
                  index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: AppColors.gold,
                ),
              if (review.displayName != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(review.displayName!, style: AppTextStyles.productName),
                ),
              ],
            ],
          ),
          if (review.verifiedPurchase) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              AppCopy.verifiedPurchase,
              style: AppTextStyles.caption.copyWith(color: AppColors.goldDark),
            ),
          ],
          if (review.text != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(review.text!, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}
