import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/minor_price.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/core/widgets/pattern_background.dart';
import 'package:e_smart/features/account/data/address_repository.dart';
import 'package:e_smart/features/branches/logic/branch_controller.dart';
import 'package:e_smart/features/cart/data/cart_repository.dart';
import 'package:e_smart/features/cart/logic/cart_controller.dart';
import 'package:e_smart/features/cart/ui/checkout_steps.dart';

enum _PayMethod { card, apple, cod }

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _details = TextEditingController();
  final _coupon = TextEditingController();

  _PayMethod _pay = _PayMethod.cod;
  var _submitting = false;
  var _quoting = false;
  String? _appliedCoupon;
  int _discountMinor = 0;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _details.dispose();
    _coupon.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    if (!ref.read(tokenProvider).isAuthenticated) {
      ref.read(toastProvider.notifier).show(AppCopy.couponLogin);
      return;
    }
    final branch = ref.read(activeBranchProvider);
    if (branch == null) {
      ref.read(toastProvider.notifier).show(AppCopy.loadError);
      return;
    }
    setState(() => _quoting = true);
    try {
      final lines = ref.read(cartProvider);
      final repo = ref.read(cartRepositoryProvider);
      await repo.syncLocalLines(
        branchId: branch.id,
        lines: [
          for (final line in lines)
            (productId: line.productId, quantity: line.quantity),
        ],
      );
      final quote = await repo.quoteCoupon(
        branchId: branch.id,
        code: _coupon.text,
      );
      if (!quote.valid || quote.discountMinor <= 0) {
        setState(() {
          _appliedCoupon = null;
          _discountMinor = 0;
        });
        ref.read(toastProvider.notifier).show(AppCopy.couponInvalid);
        return;
      }
      setState(() {
        _appliedCoupon = _coupon.text.trim().toUpperCase();
        _discountMinor = quote.discountMinor;
      });
      ref.read(toastProvider.notifier).show(AppCopy.couponApplied);
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _quoting = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!ref.read(tokenProvider).isAuthenticated) {
      context.push('/login?from=${Uri.encodeComponent('/checkout')}');
      return;
    }
    final details = _details.text.trim();
    if (details.length < 5) {
      ref.read(toastProvider.notifier).show(AppCopy.addressTooShort);
      return;
    }
    if (_pay == _PayMethod.card) {
      ref.read(toastProvider.notifier).show(AppCopy.cardDisabled);
      return;
    }
    if (_pay == _PayMethod.apple) {
      ref.read(toastProvider.notifier).show(AppCopy.cardDisabled);
      return;
    }
    final branch = ref.read(activeBranchProvider);
    final lines = ref.read(cartProvider);
    if (branch == null || lines.isEmpty) {
      ref.read(toastProvider.notifier).show(AppCopy.loadError);
      return;
    }

    final phoneRaw = _phone.text.trim();
    final phone = phoneRaw.startsWith('+')
        ? phoneRaw
        : '${AppCopy.countryCode}${phoneRaw.replaceFirst(RegExp(r'^0+'), '')}';

    setState(() => _submitting = true);
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.syncLocalLines(
        branchId: branch.id,
        lines: [
          for (final line in lines)
            (productId: line.productId, quantity: line.quantity),
        ],
      );
      if (_appliedCoupon != null) {
        await repo.quoteCoupon(branchId: branch.id, code: _appliedCoupon!);
      }
      final String addressId;
      try {
        addressId = await ref.read(addressRepositoryProvider).create(
          label: AppCopy.defaultAddressLabel,
          recipientName: _name.text.trim(),
          phone: phone,
          city: _city.text.trim(),
          details: details,
        );
      } on ServerFailure {
        ref.read(toastProvider.notifier).show(AppCopy.addressSaveFailed);
        return;
      } catch (error) {
        ref.read(toastProvider.notifier).show(failureMessage(error));
        return;
      }
      final result = await repo.checkout(
        branchId: branch.id,
        addressId: addressId,
        paymentMethod: 'cash_on_delivery',
        couponCode: _appliedCoupon,
      );
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      context.go(
        '/checkout/success'
        '?orderNumber=${Uri.encodeQueryComponent(result.orderNumber ?? '')}'
        '&id=${Uri.encodeQueryComponent(result.id)}',
      );
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartProvider);
    if (lines.isEmpty && !_submitting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/cart');
      });
    }
    final cart = ref.read(cartProvider.notifier);
    final subtotal = cart.subtotalMinor;
    final currency = cart.currency;
    final payable = (subtotal - _discountMinor).clamp(0, 1 << 30);

    return PatternBackground(
      backgroundColor: AppColors.checkoutBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final form = CheckoutPanel(
            title: AppCopy.checkout,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Field(label: AppCopy.fullName, controller: _name),
                const SizedBox(height: 12),
                _PhoneField(controller: _phone),
                const SizedBox(height: 12),
                _Field(label: AppCopy.city, controller: _city),
                const SizedBox(height: 12),
                _Field(
                  label: AppCopy.addressDetails,
                  controller: _details,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  AppCopy.pagePayment,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 10),
                _PayRow(
                  label: AppCopy.paymentCard,
                  selected: _pay == _PayMethod.card,
                  onTap: () => setState(() => _pay = _PayMethod.card),
                ),
                const SizedBox(height: 8),
                _PayRow(
                  label: AppCopy.paymentApple,
                  selected: _pay == _PayMethod.apple,
                  onTap: () => setState(() => _pay = _PayMethod.apple),
                ),
                const SizedBox(height: 8),
                _PayRow(
                  label: AppCopy.paymentCod,
                  selected: _pay == _PayMethod.cod,
                  onTap: () => setState(() => _pay = _PayMethod.cod),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: _Field(
                          label: AppCopy.coupon,
                          controller: _coupon,
                          hint: AppCopy.couponHint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _quoting ? null : _applyCoupon,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(_quoting ? '...' : AppCopy.apply),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          final summary = CheckoutPanel(
            title: AppCopy.orderSummary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SumRow(
                  label: AppCopy.subtotal,
                  value: formatMinorPrice(subtotal, currency),
                ),
                const SizedBox(height: 8),
                const _SumRow(
                  label: AppCopy.shipping,
                  value: AppCopy.shippingAtConfirm,
                ),
                if (_discountMinor > 0) ...[
                  const SizedBox(height: 8),
                  _SumRow(
                    label: AppCopy.discount,
                    value: formatMinorPrice(_discountMinor, currency),
                    valueColor: AppColors.error,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.rowDivider),
                ),
                _SumRow(
                  label: AppCopy.total,
                  value: formatMinorPrice(payable, currency),
                  emphasize: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submitting ? null : _submit,
                    child: Text(
                      _submitting
                          ? AppCopy.confirmingOrder
                          : AppCopy.confirmOrderWithTotal(
                              formatMinorPrice(payable, currency),
                            ),
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.surface,
                    ),
                    onPressed: () => context.go('/cart'),
                    child: const Text(AppCopy.backToCart),
                  ),
                ),
              ],
            ),
          );

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  const CheckoutSteps(active: 2),
                  const SizedBox(height: 16),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 14, child: form),
                        const SizedBox(width: 16),
                        SizedBox(width: 280, child: summary),
                      ],
                    )
                  else ...[
                    form,
                    const SizedBox(height: 16),
                    summary,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({
    super.key,
    this.orderNumber,
  });

  final String? orderNumber;

  @override
  Widget build(BuildContext context) {
    final number = orderNumber?.trim();
    final showNumber = number != null && number.isNotEmpty;
    return PatternBackground(
      backgroundColor: AppColors.checkoutBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CheckoutPanel(
              title: AppCopy.orderSuccess,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        color: AppColors.successText,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (showNumber) ...[
                    const SizedBox(height: 16),
                    Text(
                      AppCopy.orderNumber,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number,
                      textDirection: TextDirection.ltr,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.go('/account/orders'),
                      child: const Text(AppCopy.myOrders),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text(AppCopy.continueShopping),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        SizedBox(
          height: maxLines == 1 ? 44 : null,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTextStyles.body.copyWith(color: const Color(0xFF2B1A1B)),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppCopy.mobile, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: Row(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.fieldBorder),
                  color: AppColors.pageBackground,
                ),
                child: const Text(
                  AppCopy.countryCode,
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.label,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFF2B1A1B),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.fieldBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.fieldBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.pageBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.checkoutBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(label, style: AppTextStyles.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

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
            color: valueColor ??
                (emphasize ? AppColors.primary : AppColors.text),
            fontSize: emphasize ? 16 : 14,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
