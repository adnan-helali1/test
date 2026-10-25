import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/media_url.dart';
import 'package:e_smart/core/format/minor_price.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_shadows.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/features/products/data/product.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(widget.product.imageUrl);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: productCardDecoration(pressed: _pressed),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.productCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ColoredBox(
                  color: AppColors.pageBackground,
                  child: imageUrl == null
                      ? const SizedBox.expand()
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 480,
                          placeholder: (_, _) => const ColoredBox(
                            color: AppColors.pageBackground,
                          ),
                          errorWidget: (_, _, _) => const ColoredBox(
                            color: AppColors.pageBackground,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.productName,
                      ),
                      if (widget.product.brand.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          widget.product.brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                      const Spacer(),
                      MinorPriceText(
                        minor: widget.product.priceMinor,
                        currency: widget.product.currency,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      _Rating(rating: widget.product.averageRating),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating});

  final double? rating;

  @override
  Widget build(BuildContext context) {
    if (rating == null) {
      return Text(AppCopy.noRating, style: AppTextStyles.caption);
    }
    final rounded = rating!.round().clamp(0, 5);
    return Row(
      children: [
        for (var index = 0; index < 5; index++)
          Icon(
            index < rounded ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14,
            color: AppColors.gold,
          ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          rating!.toStringAsFixed(1),
          textDirection: TextDirection.ltr,
          style: AppTextStyles.caption.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}
