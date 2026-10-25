import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/app_buttons.dart';
import 'package:e_smart/core/widgets/pattern_background.dart';

class AccountShell extends ConsumerWidget {
  const AccountShell({super.key, required this.section, required this.child});

  final String section;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider);
    return PatternBackground(
      backgroundColor: AppColors.checkoutBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final sidebar = _Sidebar(
            section: section,
            signedIn: tokens.isAuthenticated,
            name: tokens.fullName ?? '',
            email: tokens.email ?? '',
            onLogout: () async {
              await ref.read(tokenProvider.notifier).clear();
              if (context.mounted) context.go('/');
            },
          );
          if (!wide) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                sidebar,
                const SizedBox(height: 20),
                child,
              ],
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: sidebar),
                    const SizedBox(width: 20),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AccountPanel extends StatelessWidget {
  const AccountPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.checkoutBorder),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 8),
            blurRadius: 24,
            color: Color(0x0A1C1115),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTextStyles.pageTitle.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class AccountLoginGate extends StatelessWidget {
  const AccountLoginGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountPanel(
      title: AppCopy.account,
      child: Column(
        children: [
          Text(
            AppCopy.loginRequired,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(
            label: AppCopy.login,
            onPressed: () => context.go(
              '/login?from=${Uri.encodeComponent('/account')}',
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.section,
    required this.signedIn,
    required this.name,
    required this.email,
    required this.onLogout,
  });

  final String section;
  final bool signedIn;
  final String name;
  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final source = name.isNotEmpty ? name : email;
    final initial = source.isEmpty
        ? '؟'
        : String.fromCharCodes(source.runes.take(1)).toUpperCase();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment(-0.7, -1),
                end: Alignment(0.7, 1),
                colors: [AppColors.primary, AppColors.accountSidebarEnd],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x8CD89B2B),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    initial.toUpperCase(),
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signedIn && name.isNotEmpty ? name : AppCopy.account,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.surface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, c) {
                final twoCol = c.maxWidth >= 200 && c.maxWidth < 560;
                final items = <Widget>[
                  _NavItem(
                    label: AppCopy.overview,
                    selected: section == 'overview',
                    onTap: () => context.go('/account'),
                  ),
                  _NavItem(
                    label: AppCopy.myOrders,
                    selected: section == 'orders',
                    onTap: () => context.go('/account/orders'),
                  ),
                  _NavItem(
                    label: AppCopy.wishlist,
                    selected: section == 'wishlist',
                    onTap: () => context.go('/account/wishlist'),
                  ),
                  _NavItem(
                    label: AppCopy.myAddresses,
                    selected: section == 'addresses',
                    onTap: () => context.go('/account/addresses'),
                  ),
                  _NavItem(
                    label: AppCopy.chats,
                    selected: section == 'chats',
                    onTap: () => context.go('/account/chats'),
                  ),
                  _NavItem(
                    label: AppCopy.authenticity,
                    selected: section == 'authenticity',
                    onTap: () => context.go('/account/authenticity'),
                  ),
                ];
                if (twoCol) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in items)
                        SizedBox(width: (c.maxWidth - 8) / 2, child: item),
                      const Divider(color: AppColors.rowDivider),
                      if (signedIn)
                        _NavItem(
                          label: AppCopy.logout,
                          selected: false,
                          danger: true,
                          onTap: onLogout,
                        ),
                    ],
                  );
                }
                return Column(
                  children: [
                    ...items,
                    const Divider(color: AppColors.rowDivider),
                    if (signedIn)
                      _NavItem(
                        label: AppCopy.logout,
                        selected: false,
                        danger: true,
                        onTap: onLogout,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.accountNavActive : null,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? const Border(
                  right: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: danger
                  ? AppColors.dangerText
                  : selected
                      ? AppColors.primary
                      : const Color(0xFF3D2F32),
            ),
          ),
        ),
      ),
    );
  }
}
