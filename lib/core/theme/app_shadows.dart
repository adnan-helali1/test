import 'package:flutter/material.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';

/// Light press shadow: rgba(73, 13, 14, 0.10), offset (0, 4), blur 16.
abstract final class AppShadows {
  static const press = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 16,
    color: Color(0x1A490D0E),
  );

  static const assistant = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 12,
    color: Color(0x1A490D0E),
  );

  static const toast = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 16,
    color: Color(0x14490D0E),
  );

  static const panel = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 24,
    color: Color(0x0A1C1115),
  );
}

/// Pressed card decoration. The resting card has a border and no heavy shadow.
BoxDecoration productCardDecoration({required bool pressed}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.productCard),
    border: Border.all(color: AppColors.border),
    boxShadow: pressed ? const [AppShadows.press] : null,
  );
}
