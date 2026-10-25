import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/media_url.dart';
import 'package:e_smart/core/format/minor_price.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/storage/locale_preference.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_shadows.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/features/ai/data/ai_models.dart';
import 'package:e_smart/features/ai/data/ai_repository.dart';
import 'package:e_smart/features/branches/data/branch.dart';
import 'package:e_smart/features/branches/logic/branch_controller.dart';
import 'package:e_smart/features/products/data/product.dart';

class FloatingAssistant extends ConsumerStatefulWidget {
  const FloatingAssistant({super.key});

  @override
  ConsumerState<FloatingAssistant> createState() => _FloatingAssistantState();
}

class _FloatingAssistantState extends ConsumerState<FloatingAssistant> {
  static bool _introPlayed = false;

  final _input = TextEditingController();
  final _history = <AiChatTurn>[];
  var _expandedHint = false;
  var _open = false;
  var _sending = false;
  var _available = false;
  String? _notice;
  String? _answer;
  List<Product> _items = const [];
  Timer? _introTimer;

  @override
  void initState() {
    super.initState();
    if (!_introPlayed) {
      _expandedHint = true;
      _introTimer = Timer(const Duration(seconds: 3), () {
        _introPlayed = true;
        if (mounted) setState(() => _expandedHint = false);
      });
    }
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    setState(() => _open = !_open);
    if (!_open) return;
    await _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final status = await ref.read(aiRepositoryProvider).status();
      if (!mounted) return;
      setState(() {
        _available = status.available;
        _notice = status.available ? null : AppCopy.aiDisabled;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _available = false;
        _notice = failureMessage(error);
      });
    }
  }

  Future<void> _send() async {
    final query = _input.text.trim();
    if (query.isEmpty || _sending) return;
    final branches = await ref.read(branchListProvider.future);
    Branch? branch;
    for (final item in branches) {
      if (item.active) {
        branch = item;
        break;
      }
    }
    if (branch == null) {
      ref.read(toastProvider.notifier).show(AppCopy.loadError);
      return;
    }
    setState(() => _sending = true);
    try {
      final status = await ref.read(aiRepositoryProvider).status();
      if (!status.available) {
        if (!mounted) return;
        setState(() {
          _available = false;
          _notice = AppCopy.aiDisabled;
          _sending = false;
        });
        return;
      }
      final previous = _history.length <= 10
          ? List<AiChatTurn>.of(_history)
          : _history.sublist(_history.length - 10);
      final result = await ref.read(aiRepositoryProvider).assistant(
        branchId: branch.id,
        query: query,
        locale: ref.read(localeProvider).languageCode,
        history: previous,
      );
      if (!mounted) return;
      _history.add(AiChatTurn(role: 'user', content: query));
      if (result.answer.isNotEmpty) {
        _history.add(AiChatTurn(role: 'assistant', content: result.answer));
      }
      setState(() {
        _available = true;
        _notice = result.catalogTruncated
            ? AppCopy.truncatedCatalog(result.catalogProductsConsidered)
            : null;
        _answer = result.answer;
        _items = result.items;
        _sending = false;
        _input.clear();
      });
    } on AiNotConfiguredFailure {
      if (!mounted) return;
      setState(() {
        _available = false;
        _notice = AppCopy.aiDisabled;
        _sending = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      ref.read(toastProvider.notifier).show(failureMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_open) _panel(),
            const SizedBox(height: AppSpacing.xs),
            _launcher(),
          ],
        ),
      ),
    );
  }

  Widget _launcher() {
    return Material(
      color: AppColors.primary,
      elevation: 0,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: _toggle,
        child: Container(
          height: 44,
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: _expandedHint ? 14 : 0,
          ),
          constraints: const BoxConstraints(minWidth: 44),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(9999)),
            boxShadow: [AppShadows.assistant],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 44,
                child: Icon(Icons.auto_awesome, color: AppColors.surface, size: 20),
              ),
              if (_expandedHint)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 12),
                  child: Text(AppCopy.assistantHint, style: AppTextStyles.assistantHint),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel() {
    return Material(
      color: AppColors.assistantSurface,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppRadius.assistantPanel),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 360),
        decoration: BoxDecoration(
          color: AppColors.assistantSurface,
          borderRadius: BorderRadius.circular(AppRadius.assistantPanel),
          border: Border.all(color: AppColors.assistantBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.assistantPanel),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    tooltip: AppCopy.close,
                    onPressed: () => setState(() => _open = false),
                    icon: const Text('✕', style: TextStyle(color: AppColors.surface)),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(AppSpacing.sm),
                children: [
                  if (_notice != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(_notice!, style: AppTextStyles.caption),
                    ),
                  if (_answer != null && _answer!.isNotEmpty)
                    Text(_answer!, style: AppTextStyles.body),
                  if (_items.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    for (final product in _items)
                      _SuggestedProduct(
                        product: product,
                        onTap: () => context.push('/products/${product.id}'),
                      ),
                  ],
                ],
              ),
            ),
            if (_available)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: AppCopy.searchHint,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      tooltip: AppCopy.send,
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.send, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedProduct extends StatelessWidget {
  const _SuggestedProduct({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(product.imageUrl);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: SizedBox(
            width: 48,
            height: 48,
            child: ColoredBox(
              color: AppColors.pageBackground,
              child: imageUrl == null
                  ? const SizedBox.expand()
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const SizedBox.expand(),
                    ),
            ),
          ),
        ),
        title: Text(product.name, style: AppTextStyles.productName),
        subtitle: Text(product.brand, style: AppTextStyles.caption),
        trailing: MinorPriceText(
          minor: product.priceMinor,
          currency: product.currency,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
