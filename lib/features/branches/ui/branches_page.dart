import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/async_page.dart';
import 'package:e_smart/core/widgets/surface_card.dart';
import 'package:e_smart/features/branches/data/branch.dart';
import 'package:e_smart/features/branches/logic/branch_controller.dart';

class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchListProvider);
    return AsyncPage<List<Branch>>(
      value: branches,
      onRetry: () => ref.read(branchListProvider.notifier).refresh(),
      data: (items) {
        final active = [for (final branch in items) if (branch.active) branch];
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await ref.read(branchListProvider.notifier).refresh();
          },
          child: active.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    LoadFailure(
                      message: AppCopy.loadError,
                      onRetry: () => ref.read(branchListProvider.notifier).refresh(),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: PageScaffoldPadding.edge,
                  itemCount: active.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(AppCopy.branches, style: AppTextStyles.pageTitle);
                    }
                    final branch = active[index - 1];
                    return _BranchTile(branch: branch);
                  },
                ),
        );
      },
    );
  }
}

class BranchDetailsPage extends ConsumerWidget {
  const BranchDetailsPage({super.key, required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchListProvider);
    return AsyncPage<List<Branch>>(
      value: branches,
      onRetry: () => ref.read(branchListProvider.notifier).refresh(),
      data: (items) {
        Branch? match;
        for (final branch in items) {
          if (branch.id == branchId) match = branch;
        }
        if (match == null) {
          return LoadFailure(
            message: AppCopy.loadError,
            onRetry: () => ref.read(branchListProvider.notifier).refresh(),
          );
        }
        return ListView(
          padding: PageScaffoldPadding.edge,
          children: [
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.name, style: AppTextStyles.pageTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 18, color: AppColors.goldDark),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          match.phone ?? AppCopy.noPhone,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      radius: AppRadius.productCard,
      onTap: () => context.push('/branches/${branch.id}'),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.borderWarm),
          ),
          child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 22),
        ),
        title: Text(branch.name, style: AppTextStyles.productName),
        subtitle: Text(
          branch.phone ?? AppCopy.noPhone,
          style: AppTextStyles.caption,
        ),
        trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
      ),
    );
  }
}
