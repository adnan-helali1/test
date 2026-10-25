import 'package:flutter/widgets.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';

/// Formats minor units without binary floating point.
/// 1100 and SAR become `11.00 SAR`.
String formatMinorPrice(int minor, String currency) {
  final negative = minor < 0;
  final value = minor.abs();
  final whole = value ~/ 100;
  final fraction = (value % 100).toString().padLeft(2, '0');
  final amount = '$whole.$fraction $currency';
  return negative ? '-$amount' : amount;
}

/// Keeps the amount and currency code in left-to-right order inside RTL text.
class MinorPriceText extends StatelessWidget {
  const MinorPriceText({
    super.key,
    required this.minor,
    required this.currency,
    this.style,
  });

  final int minor;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatMinorPrice(minor, currency),
      textDirection: TextDirection.ltr,
      style: style ?? AppTextStyles.price,
    );
  }
}
