import 'package:flutter/material.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/empty_state.dart';
import 'package:e_smart/core/widgets/pattern_background.dart';
import 'package:e_smart/features/content/data/static_pages.dart';

class StaticPageView extends StatelessWidget {
  const StaticPageView({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final page = staticPageBySlug(slug);
    if (page == null) {
      return const PatternBackground(
        child: Center(child: EmptyState(message: '—', icon: Icons.article_outlined)),
      );
    }
    return PatternBackground(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.checkoutBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        page.title,
                        style: AppTextStyles.pageTitle.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.body,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
