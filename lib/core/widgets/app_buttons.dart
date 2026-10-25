import 'package:flutter/material.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.surface,
              ),
            )
          : Text(label, style: AppTextStyles.button.copyWith(color: AppColors.surface)),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class AppGoldButton extends StatelessWidget {
  const AppGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.text,
        disabledBackgroundColor: AppColors.goldLight,
        disabledForegroundColor: AppColors.textSecondary,
        textStyle: AppTextStyles.button,
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryNormal,
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          backgroundColor: AppColors.surface,
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryNormal,
                ),
              )
            : Text(label),
      ),
    );
  }
}
