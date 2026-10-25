import 'package:flutter/material.dart';
import 'package:e_smart/core/theme/app_colors.dart';

/// Store content background.
/// Layer order: page `#FAF6F7` → tiled `bg-nuqoosh.jpg` at 0.72 → content.
/// Tile width stays 520 logical px; image is never recolored or cropped to a logo.
///
/// When `assets/images/bg-nuqoosh.jpg` is missing, only the flat page color shows.
class PatternBackground extends StatelessWidget {
  const PatternBackground({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.pageBackground,
  });

  final Widget child;
  final Color backgroundColor;

  static const assetPath = 'assets/images/bg-nuqoosh.jpg';
  static const tileWidth = 520.0;
  static const tileOpacity = 0.72;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: backgroundColor),
        const Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(child: _NuqooshTile()),
          ),
        ),
        child,
      ],
    );
  }
}

class _NuqooshTile extends StatelessWidget {
  const _NuqooshTile();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: PatternBackground.tileOpacity,
      child: Image.asset(
        PatternBackground.assetPath,
        repeat: ImageRepeat.repeat,
        alignment: Alignment.topCenter,
        width: PatternBackground.tileWidth,
        fit: BoxFit.none,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => const SizedBox.expand(),
      ),
    );
  }
}
