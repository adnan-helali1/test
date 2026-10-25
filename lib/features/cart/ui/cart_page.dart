import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/media_url.dart';
import 'package:e_smart/core/format/minor_price.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/app_buttons.dart';
import 'package:e_smart/core/widgets/pattern_background.dart';
import 'package:e_smart/features/cart/data/cart_line.dart';
import 'package:e_smart/features/cart/logic/cart_controller.dart';
import 'package:e_smart/features/cart/ui/checkout_steps.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    return PatternBackground(
      backgroundColor: AppColors.checkoutBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final content = lines.isEmpty
              ? const _EmptyCart()
              : _CartBody(lines: lines, wide: wide);
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  const CheckoutSteps(active: 1),
                  const SizedBox(height: 16),
                  content,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return CheckoutPanel(
      title: AppCopy.cartTitle,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            AppCopy.cartEmpty,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: AppCopy.browseProducts,
            onPressed: () => context.go('/products'),
          ),
        ],
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({required this.lines, required this.wide});

  final List<CartLine> lines;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final subtotal = cart.subtotalMinor;
    final currency = cart.currency;
    final shipping = cartShippingDisplaySar;
    final totalMinor = subtotal + shipping * 100;

    final linesPanel = CheckoutPanel(
      title: AppCopy.cartTitle,
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            _CartRow(line: lines[i], compact: !wide),
            if (i < lines.length - 1)
              const Divider(height: 1, color: AppColors.rowDivider),
          ],
        ],
      ),
    );

    final summary = CheckoutPanel(
      title: AppCopy.orderSummary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            label: AppCopy.subtotal,
            value: formatMinorPrice(subtotal, currency),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: AppCopy.shipping,
            value: '$shipping ${AppCopy.sar}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.rowDivider),
          ),
          _SummaryRow(
            label: AppCopy.total,
            value: formatMinorPrice(totalMinor, currency),
            emphasize: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.button.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => context.go('/checkout'),
              child: const Text(AppCopy.continueCheckout),
            ),
          ),
        ],
      ),
    );

    if (!wide) {
      return Column(
        children: [
          linesPanel,
          const SizedBox(height: 16),
          summary,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 14, child: linesPanel),
        const SizedBox(width: 16),
        SizedBox(width: 280, child: summary),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textBody,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: AppTextStyles.body.copyWith(
            color: emphasize ? AppColors.primary : AppColors.text,
            fontSize: emphasize ? 16 : 14,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _CartRow extends ConsumerWidget {
  const _CartRow({required this.line, required this.compact});

  final CartLine line;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = resolveMediaUrl(line.imageUrl);
    final imageSize = compact ? 64.0 : 72.0;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            border: Border.all(color: AppColors.checkoutBorder),
          ),
          child: imageUrl == null
              ? const SizedBox.expand()
              : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line.name,
          style: AppTextStyles.label.copyWith(
            color: AppColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppCopy.cartAvailable,
          style: AppTextStyles.caption.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 8),
        _Qty(
          quantity: line.quantity,
          onChanged: (q) =>
              ref.read(cartProvider.notifier).setQuantity(line.productId, q),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => ref.read(cartProvider.notifier).remove(line.productId),
          child: Text(
            AppCopy.remove,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.dangerText,
              fontSize: 12,
            ),
          ),
        ),
        if (compact) ...[
          const SizedBox(height: 8),
          MinorPriceText(
            minor: line.lineTotalMinor,
            currency: line.currency,
            style: AppTextStyles.price.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );

    final price = MinorPriceText(
      minor: line.lineTotalMinor,
      currency: line.currency,
      style: AppTextStyles.price.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: compact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                const SizedBox(width: 12),
                Expanded(child: info),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                const SizedBox(width: 12),
                Expanded(child: info),
                price,
              ],
            ),
    );
  }
}

class _Qty extends StatelessWidget {
  const _Qty({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _QtyBtn(
            icon: Icons.add,
            onTap: quantity < 100 ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pageBackground,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      ),
    );
  }
}
