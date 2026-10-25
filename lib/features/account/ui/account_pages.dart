import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/minor_price.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/app_buttons.dart';
import 'package:e_smart/core/widgets/async_page.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/core/widgets/empty_state.dart';
import 'package:e_smart/core/widgets/product_card.dart';
import 'package:e_smart/features/account/data/address.dart';
import 'package:e_smart/features/account/data/address_repository.dart';
import 'package:e_smart/features/account/data/authenticity_repository.dart';
import 'package:e_smart/features/account/data/order.dart';
import 'package:e_smart/features/account/data/support_repository.dart';
import 'package:e_smart/features/account/logic/account_providers.dart';
import 'package:e_smart/features/account/ui/account_shell.dart';
import 'package:e_smart/features/wishlist/logic/wishlist_controller.dart';

class AccountOverviewPage extends ConsumerWidget {
  const AccountOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider);
    return AccountShell(
      section: 'overview',
      child: !tokens.isAuthenticated
          ? const AccountLoginGate()
          : _OverviewBody(
              name: tokens.fullName ?? '',
              email: tokens.email ?? '',
            ),
    );
  }
}

class _OverviewBody extends ConsumerWidget {
  const _OverviewBody({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(accountOverviewCountsProvider);
    return AccountPanel(
      title: AppCopy.overview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppCopy.welcomeName(name.isNotEmpty ? name : AppCopy.account),
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            AppCopy.accountIntro,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppPrimaryButton(
              label: AppCopy.continueShopping,
              expanded: false,
              onPressed: () => context.go('/products'),
            ),
          ),
          const SizedBox(height: 20),
          counts.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(failureMessage(e)),
            data: (c) => LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final cross = w < 560 ? 1 : (w < 900 ? 2 : 4);
                return GridView.count(
                  crossAxisCount: cross,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _StatCard(label: AppCopy.ordersCount, value: c.orders),
                    _StatCard(label: AppCopy.wishlistCount, value: c.wishlist),
                    _StatCard(
                      label: AppCopy.addressesCount,
                      value: c.addresses,
                    ),
                    _StatCard(label: AppCopy.chatsCount, value: c.chats),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(AppCopy.shortcuts, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Shortcut(
                label: AppCopy.myOrders,
                onTap: () => context.go('/account/orders'),
              ),
              _Shortcut(
                label: AppCopy.wishlist,
                onTap: () => context.go('/account/wishlist'),
              ),
              _Shortcut(
                label: AppCopy.myAddresses,
                onTap: () => context.go('/account/addresses'),
              ),
              _Shortcut(
                label: AppCopy.chats,
                onTap: () => context.go('/account/chats'),
              ),
              _Shortcut(
                label: AppCopy.authenticity,
                onTap: () => context.go('/account/authenticity'),
              ),
              _Shortcut(
                label: AppCopy.trackOrder,
                onTap: () => context.go('/pages/track-order'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(AppCopy.accountDetails, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          _DetailRow(label: AppCopy.fullName, value: name),
          const Divider(color: AppColors.rowDivider),
          _DetailRow(label: AppCopy.email, value: email, ltr: true),
          const Divider(color: AppColors.rowDivider),
          const _DetailRow(
            label: AppCopy.status,
            value: AppCopy.accountActive,
            valueColor: AppColors.successText,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.checkoutBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.checkoutBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_outward,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.ltr = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool ltr;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.caption),
          ),
          Text(
            value.isEmpty ? '—' : value,
            textDirection: ltr ? TextDirection.ltr : null,
            style: AppTextStyles.label.copyWith(
              color: valueColor ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountOrdersPage extends ConsumerWidget {
  const AccountOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider);
    final orders = ref.watch(accountOrdersProvider);
    return AccountShell(
      section: 'orders',
      child: !tokens.isAuthenticated
          ? const AccountLoginGate()
          : AccountPanel(
              title: AppCopy.myOrders,
              child: AsyncPage<List<StoreOrder>>(
                value: orders,
                onRetry: () async {
                  ref.invalidate(accountOrdersProvider);
                },
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(
                      message: AppCopy.noOrders,
                      icon: Icons.receipt_long_outlined,
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text(AppCopy.order)),
                        DataColumn(label: Text(AppCopy.status)),
                        DataColumn(label: Text(AppCopy.amount)),
                        DataColumn(label: Text(AppCopy.date)),
                        DataColumn(label: Text(AppCopy.track)),
                      ],
                      rows: [
                        for (final order in items)
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  order.orderNumber ?? '—',
                                  textDirection: TextDirection.ltr,
                                ),
                              ),
                              DataCell(_StatusChip(label: order.statusLabel)),
                              DataCell(
                                Text(
                                  order.currency.toUpperCase() == 'SAR'
                                      ? '${formatMinorPrice(order.totalMinor, '').trim()} ${AppCopy.sar}'
                                      : formatMinorPrice(
                                          order.totalMinor,
                                          order.currency,
                                        ),
                                  textDirection: TextDirection.ltr,
                                ),
                              ),
                              DataCell(Text(order.dateLabel ?? '—')),
                              DataCell(
                                TextButton(
                                  onPressed: () => context.go(
                                    '/account/orders/${order.id}',
                                  ),
                                  child: const Text(AppCopy.track),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.successText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AccountWishlistPage extends ConsumerWidget {
  const AccountWishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider);
    final products = ref.watch(wishlistProductsProvider);
    return AccountShell(
      section: 'wishlist',
      child: !tokens.isAuthenticated
          ? const AccountLoginGate()
          : AccountPanel(
              title: AppCopy.wishlist,
              child: AsyncPage(
                value: products,
                onRetry: () async {
                  ref.invalidate(wishlistProductsProvider);
                },
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(
                      message: AppCopy.noWishlist,
                      icon: Icons.favorite_border,
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.go('/products/${product.id}'),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class AccountAddressesPage extends ConsumerStatefulWidget {
  const AccountAddressesPage({super.key});

  @override
  ConsumerState<AccountAddressesPage> createState() =>
      _AccountAddressesPageState();
}

class _AccountAddressesPageState extends ConsumerState<AccountAddressesPage> {
  final _label = TextEditingController();
  final _city = TextEditingController();
  final _details = TextEditingController();
  final _phone = TextEditingController();
  final _name = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _city.dispose();
    _details.dispose();
    _phone.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final details = _details.text.trim();
    if (details.length < 5) {
      ref.read(toastProvider.notifier).show(AppCopy.addressTooShort);
      return;
    }
    setState(() => _saving = true);
    try {
      final tokens = ref.read(tokenProvider);
      await ref.read(addressRepositoryProvider).create(
        label: _label.text.trim().isEmpty
            ? AppCopy.defaultAddressLabel
            : _label.text.trim(),
        recipientName: _name.text.trim().isEmpty
            ? (tokens.fullName ?? '')
            : _name.text.trim(),
        phone: _phone.text.trim(),
        city: _city.text.trim(),
        details: details,
      );
      ref.invalidate(accountAddressesProvider);
      _label.clear();
      _city.clear();
      _details.clear();
      _phone.clear();
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ref.watch(tokenProvider);
    final addresses = ref.watch(accountAddressesProvider);
    return AccountShell(
      section: 'addresses',
      child: !tokens.isAuthenticated
          ? const AccountLoginGate()
          : AccountPanel(
              title: AppCopy.myAddresses,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AsyncPage<List<Address>>(
                    value: addresses,
                    onRetry: () async {
                      ref.invalidate(accountAddressesProvider);
                    },
                    data: (items) {
                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: EmptyState(
                            message: AppCopy.noAddresses,
                            icon: Icons.location_on_outlined,
                          ),
                        );
                      }
                      return LayoutBuilder(
                        builder: (context, c) {
                          final two = c.maxWidth >= 900;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: two ? 2 : 1,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: two ? 2.4 : 2.8,
                            ),
                            itemBuilder: (context, i) {
                              final a = items[i];
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.checkoutBorder,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.label,
                                        style: AppTextStyles.label.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(a.city, style: AppTextStyles.caption),
                                      Text(
                                        a.details,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(AppCopy.save, style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _label,
                    decoration: const InputDecoration(labelText: AppCopy.label),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    decoration:
                        const InputDecoration(labelText: AppCopy.fullName),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: AppCopy.city),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _details,
                    decoration:
                        const InputDecoration(labelText: AppCopy.details),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: AppCopy.phone),
                  ),
                  const SizedBox(height: 12),
                  AppPrimaryButton(
                    label: AppCopy.save,
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}

class AccountChatsPage extends ConsumerStatefulWidget {
  const AccountChatsPage({super.key});

  @override
  ConsumerState<AccountChatsPage> createState() => _AccountChatsPageState();
}

class _AccountChatsPageState extends ConsumerState<AccountChatsPage> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  var _creating = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      await ref.read(supportRepositoryProvider).create(
        kind: 'support',
        subject: _subject.text.trim(),
        message: _message.text.trim(),
      );
      ref.invalidate(accountChatsProvider);
      _subject.clear();
      _message.clear();
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ref.watch(tokenProvider);
    final chats = ref.watch(accountChatsProvider);
    return AccountShell(
      section: 'chats',
      child: !tokens.isAuthenticated
          ? const AccountLoginGate()
          : AccountPanel(
              title: AppCopy.chats,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AsyncPage(
                    value: chats,
                    onRetry: () async {
                      ref.invalidate(accountChatsProvider);
                    },
                    data: (items) {
                      if (items.isEmpty) {
                        return const EmptyState(
                          message: AppCopy.noChats,
                          icon: Icons.chat_bubble_outline,
                        );
                      }
                      return Column(
                        children: [
                          for (final chat in items)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                chat.subject ?? chat.id,
                                style: AppTextStyles.label,
                              ),
                              subtitle: chat.kind == null
                                  ? null
                                  : Text(chat.kind!),
                              onTap: () =>
                                  context.go('/account/chats/${chat.id}'),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(AppCopy.newChat, style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subject,
                    decoration:
                        const InputDecoration(labelText: AppCopy.subject),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _message,
                    decoration:
                        const InputDecoration(labelText: AppCopy.message),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  AppPrimaryButton(
                    label: AppCopy.send,
                    loading: _creating,
                    onPressed: _create,
                  ),
                ],
              ),
            ),
    );
  }
}

class AccountAuthenticityPage extends ConsumerStatefulWidget {
  const AccountAuthenticityPage({super.key});

  @override
  ConsumerState<AccountAuthenticityPage> createState() =>
      _AccountAuthenticityPageState();
}

class _AccountAuthenticityPageState
    extends ConsumerState<AccountAuthenticityPage> {
  final _code = TextEditingController();
  var _loading = false;
  AuthenticityResult? _result;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _code.text.trim();
    if (token.isEmpty) return;
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final result =
          await ref.read(authenticityRepositoryProvider).verify(token);
      setState(() => _result = result);
      if (result.notFound && result.message != null) {
        ref.read(toastProvider.notifier).show(result.message!);
      }
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final borderColor = result == null
        ? AppColors.checkoutBorder
        : (result.firstScan == false
            ? AppColors.gold
            : AppColors.authenticityFirst);
    return AccountShell(
      section: 'authenticity',
      child: AccountPanel(
        title: AppCopy.authenticityTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppCopy.authenticityIntro,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              decoration: const InputDecoration(
                labelText: AppCopy.verifyCode,
                hintText: AppCopy.verifyHint,
              ),
            ),
            const SizedBox(height: 12),
            AppPrimaryButton(
              label: AppCopy.verifyNow,
              loading: _loading,
              onPressed: _verify,
            ),
            if (result != null && !result.notFound) ...[
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (result.message != null)
                        Text(result.message!, style: AppTextStyles.body),
                      if (result.productName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          result.productName!,
                          style: AppTextStyles.sectionTitle,
                        ),
                      ],
                      if (result.certificateNo != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          result.certificateNo!,
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.label,
                        ),
                      ],
                      if (result.scannedAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          result.scannedAt!,
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
