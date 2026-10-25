import 'package:flutter/material.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';

/// Checkout progress: 1 cart, 2 shipping, 3 confirm. [active] is 1-based.
class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    const labels = [
      AppCopy.stepCart,
      AppCopy.stepShipping,
      AppCopy.stepConfirm,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.checkoutBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0)
                Container(
                  width: 28,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.border,
                ),
              _Step(
                index: i + 1,
                label: labels[i],
                done: i + 1 < active,
                current: i + 1 == active,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.label,
    required this.done,
    required this.current,
  });

  final int index;
  final String label;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String mark;
    if (done) {
      bg = AppColors.successSoft;
      fg = AppColors.successText;
      mark = '✓';
    } else if (current) {
      bg = AppColors.primary;
      fg = AppColors.surface;
      mark = '$index';
    } else {
      bg = AppColors.stepIdle;
      fg = AppColors.textSecondary;
      mark = '$index';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Text(
            mark,
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: current || done ? AppColors.text : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class CheckoutPanel extends StatelessWidget {
  const CheckoutPanel({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.checkoutBorder),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 8),
            blurRadius: 24,
            color: Color(0x0A1C1115),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTextStyles.pageTitle.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
