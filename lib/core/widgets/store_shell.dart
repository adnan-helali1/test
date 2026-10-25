import 'package:flutter/material.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/widgets/floating_assistant.dart';
import 'package:e_smart/core/widgets/pattern_background.dart';
import 'package:e_smart/core/widgets/store_header.dart';

class StoreShell extends StatelessWidget {
  const StoreShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const StoreHeader(),
          Expanded(
            child: Stack(
              children: [
                PatternBackground(child: child),
                const FloatingAssistant(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
