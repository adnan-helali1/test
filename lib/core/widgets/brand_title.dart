import 'package:flutter/material.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';

/// Initials stand in until a real logo asset is added. Do not distort that logo.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.goldLight, width: 1.5),
          ),
          alignment: Alignment.center,
          child: const Text(
            'دن',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.surface,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(AppCopy.brandName, style: AppTextStyles.brand),
      ],
    );
  }
}
