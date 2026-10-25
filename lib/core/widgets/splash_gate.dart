import 'package:flutter/material.dart';
import 'package:e_smart/core/theme/splash_colors.dart';

/// First Flutter frame while session restore runs.
/// Matches native splash burgundy so there is no white/black flash.
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  static const logoAsset = 'assets/images/dar_nassri_splash_mark.png';

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: SplashColors.background,
      child: Center(
        child: Image(
          image: AssetImage(logoAsset),
          width: 220,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
