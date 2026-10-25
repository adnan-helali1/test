import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/storage/locale_preference.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/async_page.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/core/widgets/empty_state.dart';
import 'package:e_smart/core/widgets/product_card.dart';
import 'package:e_smart/core/widgets/surface_card.dart';
import 'package:e_smart/features/ai/data/ai_repository.dart';
import 'package:e_smart/features/branches/data/branch.dart';
import 'package:e_smart/features/branches/logic/branch_controller.dart';
import 'package:e_smart/features/products/data/product.dart';
import 'package:e_smart/features/products/logic/product_controller.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  var _loading = true;
  var _aiEnabled = false;
  String? _notice;
  String? _answer;
  List<Product> _aiItems = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _load();
    }
  }

  List<Product> get _localMatches {
    final loaded = ref.read(catalogProvider).valueOrNull?.items ?? const <Product>[];
    final query = widget.query.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return [
      for (final product in loaded)
        if (product.name.toLowerCase().contains(query)) product,
    ];
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _notice = null;
      _answer = null;
      _aiItems = const [];
    });
    if (widget.query.trim().isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final branches = await ref.read(branchListProvider.future);
    Branch? branch;
    for (final item in branches) {
      if (item.active) {
        branch = item;
        break;
      }
    }
    if (branch == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final status = await ref.read(aiRepositoryProvider).status();
      if (!status.available) {
        if (!mounted) return;
        setState(() {
          _aiEnabled = false;
          _notice = AppCopy.aiDisabled;
          _loading = false;
        });
        return;
      }
      final result = await ref.read(aiRepositoryProvider).search(
        branchId: branch.id,
        query: widget.query.trim(),
        locale: ref.read(localeProvider).languageCode,
      );
      if (!mounted) return;
      setState(() {
        _aiEnabled = true;
        _answer = result.answer;
        _aiItems = result.items;
        _notice = result.catalogTruncated
            ? AppCopy.truncatedCatalog(result.catalogProductsConsidered)
            : null;
        _loading = false;
      });
    } on AiNotConfiguredFailure {
      if (!mounted) return;
      setState(() {
        _aiEnabled = false;
        _notice = AppCopy.aiDisabled;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ref.read(toastProvider.notifier).show(failureMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = _aiEnabled ? const <Product>[] : _localMatches;
    final items = _aiEnabled ? _aiItems : local;
    return ListView(
      padding: PageScaffoldPadding.edge,
      children: [
        Text(widget.query, style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.md),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        if (_notice != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SurfaceCard(
              child: Text(_notice!, style: AppTextStyles.body),
            ),
          ),
        if (_answer != null && _answer!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SurfaceCard(
              child: Text(_answer!, style: AppTextStyles.body),
            ),
          ),
        if (!_loading && items.isEmpty)
          const EmptyState(message: AppCopy.noProducts)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.gridGap,
              crossAxisSpacing: AppSpacing.gridGap,
              childAspectRatio: 0.58,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCard(
                product: product,
                onTap: () => context.push('/products/${product.id}'),
              );
            },
          ),
      ],
    );
  }
}
