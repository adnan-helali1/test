import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/storage/locale_preference.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/brand_title.dart';
import 'package:e_smart/features/cart/logic/cart_controller.dart';

class StoreHeader extends ConsumerStatefulWidget {
  const StoreHeader({super.key});

  @override
  ConsumerState<StoreHeader> createState() => _StoreHeaderState();
}

class _StoreHeaderState extends ConsumerState<StoreHeader> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _searchSubmit() {
    final query = _search.text.trim();
    if (query.isEmpty) return;
    context.go('/search?q=${Uri.encodeQueryComponent(query)}');
  }

  @override
  Widget build(BuildContext context) {
    final section = _section(GoRouterState.of(context).uri);
    final tokens = ref.watch(tokenProvider);
    final locale = ref.watch(localeProvider);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 36,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.primary,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.topBar,
                    children: [
                      const TextSpan(text: 'مرحباً بك في '),
                      TextSpan(
                        text: AppCopy.brandName,
                        style: AppTextStyles.topBar.copyWith(
                          color: AppColors.gold,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: const BrandTitle(),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SearchField(controller: _search, onSubmit: _searchSubmit),
                const SizedBox(height: AppSpacing.xs),
                _Actions(
                  signedIn: tokens.isAuthenticated,
                  label: tokens.fullName ?? tokens.email ?? '',
                  localeCode: locale.languageCode,
                  onLocale: (code) => ref.read(localeProvider.notifier).setCode(code),
                  onLogout: () async {
                    await ref.read(tokenProvider.notifier).clear();
                    if (context.mounted) context.go('/');
                  },
                ),
              ],
            ),
          ),
          _CategoryStrip(section: section),
        ],
      ),
    );
  }
}

String _section(Uri uri) {
  if (uri.path.startsWith('/branches')) return 'branches';
  if (uri.path.startsWith('/brands')) return 'brands';
  if (uri.path == '/products' && uri.queryParameters['section'] == 'perfumes') {
    return 'perfumes';
  }
  if (uri.path.startsWith('/products')) return 'products';
  if (uri.path == '/') return 'home';
  return '';
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSubmit(),
              style: AppTextStyles.body.copyWith(color: AppColors.text),
              decoration: const InputDecoration(
                hintText: AppCopy.searchHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsetsDirectional.fromSTEB(18, 12, 8, 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onSubmit,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.search, size: 20, color: AppColors.surface),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({
    required this.signedIn,
    required this.label,
    required this.localeCode,
    required this.onLocale,
    required this.onLogout,
  });

  final bool signedIn;
  final String label;
  final String localeCode;
  final ValueChanged<String> onLocale;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _HeaderIcon(
            tooltip: AppCopy.cart,
            icon: Icons.shopping_bag_outlined,
            badge: cartCount,
            onPressed: () => context.go('/cart'),
          ),
          _HeaderIcon(
            tooltip: AppCopy.wishlist,
            icon: Icons.favorite_border,
            onPressed: () => context.go('/wishlist'),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 6),
            child: Icon(
              Icons.notifications_none,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: AppCopy.language,
            initialValue: localeCode,
            onSelected: onLocale,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              side: const BorderSide(color: AppColors.border),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'ar', child: Text('العربية')),
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'tr', child: Text('Türkçe')),
            ],
            child: const Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Icon(Icons.language, color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (signedIn) ...[
            TextButton(
              onPressed: () => context.go('/account'),
              child: Text(
                label.isNotEmpty ? label : AppCopy.account,
                style: AppTextStyles.caption.copyWith(color: AppColors.text),
              ),
            ),
            TextButton(onPressed: onLogout, child: const Text(AppCopy.logout)),
          ] else ...[
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(AppCopy.login),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text(AppCopy.createAccount),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.badge = 0,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: badge > 0,
        backgroundColor: AppColors.primary,
        label: Text(
          '$badge',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('home', AppCopy.home, '/'),
      ('perfumes', AppCopy.perfumes, '/products?section=perfumes'),
      ('products', AppCopy.products, '/products'),
      ('branches', AppCopy.branches, '/branches'),
      ('brands', AppCopy.brands, '/brands'),
    ];
    return ColoredBox(
      color: AppColors.navStrip,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          children: [
            for (final item in items)
              _CategoryLink(
                label: item.$2,
                selected: section == item.$1,
                onTap: () => context.go(item.$3),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryLink extends StatelessWidget {
  const _CategoryLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.gold : const Color(0x00000000),
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.navLink.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.text : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
