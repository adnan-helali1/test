import 'package:flutter/material.dart';

/// Dar Nasri locked palette from the store build order.
/// Do not approximate or replace with Material defaults.
abstract final class AppColors {
  static const primary = Color(0xFF490D0E);
  static const primaryHover = Color(0xFF3A0A0B);
  static const primaryActive = Color(0xFF2E0809);
  static const primaryMid = Color(0xFF5B1A2B);

  /// Semantic aliases used by theme / buttons.
  static const primaryNormal = primary;
  static const primaryNormalHover = primaryHover;
  static const primaryNormalActive = primaryActive;

  static const pageBackground = Color(0xFFFAF6F7);
  static const checkoutBackground = Color(0xFFF5F2F0);
  static const surface = Color(0xFFFFFFFF);
  static const navStrip = Color(0xFFF4F0EC);

  static const text = Color(0xFF1C1115);
  static const textSecondary = Color(0xFF756B6D);
  static const textBody = Color(0xFF5E4B48);
  static const textOnDark = Color(0xFFE8DDE1);
  static const textNormal = text;
  static const textLight = textOnDark;

  static const cream = Color(0xFFFBF4E8);
  static const border = Color(0xFFE8DDE1);
  static const borderWarm = Color(0xFFE8E1DC);
  static const checkoutBorder = Color(0xFFEBE4E6);
  static const fieldBorder = Color(0xFFE4D8DB);
  static const rowDivider = Color(0xFFF0ECEA);

  static const gold = Color(0xFFD89B2B);
  static const goldLight = Color(0xFFF5ECD0);
  static const goldDark = Color(0xFFB07820);

  static const success = Color(0xFF2E7D32);
  static const successSoft = Color(0xFFE6F4EA);
  static const successText = Color(0xFF2A7A45);
  static const error = Color(0xFFD32F2F);
  static const dangerText = Color(0xFFAA3333);

  static const toastBorder = Color(0xFFECECEC);
  static const assistantSurface = Color(0xFFFFFDF8);
  static const assistantBorder = Color(0xFFD7C4A2);

  static const stepIdle = Color(0xFFEFE8EA);
  static const accountNavActive = Color(0xFFFAF0F1);
  static const accountSidebarEnd = Color(0xFF6A1A2A);
  static const authenticityFirst = Color(0xFF2F6B3A);
}
