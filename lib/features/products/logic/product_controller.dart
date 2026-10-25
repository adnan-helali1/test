import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/features/branches/data/branch.dart';
import 'package:e_smart/features/branches/logic/branch_controller.dart';
import 'package:e_smart/features/products/data/product.dart';
import 'package:e_smart/features/products/data/product_repository.dart';

class CatalogController extends AsyncNotifier<CatalogPageData> {
  int _requestId = 0;
  bool _loadingMore = false;

  @override
  Future<CatalogPageData> build() async {
    _loadingMore = false;
    final requestId = ++_requestId;
    final branch = await _activeBranch(watch: true);
    final page = await ref.read(productRepositoryProvider).getProducts(
      branchId: branch.id,
      page: 1,
    );
    if (requestId != _requestId) {
      return state.valueOrNull ?? page;
    }
    return page;
  }

  Future<Branch> _activeBranch({required bool watch}) async {
    final List<Branch> branches;
    if (watch) {
      branches = await ref.watch(branchListProvider.future);
    } else {
      branches =
          ref.read(branchListProvider).valueOrNull ??
          await ref.read(branchListProvider.future);
    }
    for (final branch in branches) {
      if (branch.active) return branch;
    }
    throw StateError('no-active-branch');
  }

  Future<AppFailure?> refresh() async {
    final previous = state.valueOrNull;
    try {
      final branch = await _activeBranch(watch: false);
      final page = await ref.read(productRepositoryProvider).getProducts(
        branchId: branch.id,
        page: 1,
      );
      state = AsyncData(page);
      return null;
    } on AppFailure catch (error) {
      if (previous != null) state = AsyncData(previous);
      return error;
    }
  }

  Future<AppFailure?> loadMore() async {
    final current = state.valueOrNull;
    if (_loadingMore || current == null || !current.hasMore || current.loadingMore) {
      return null;
    }
    _loadingMore = true;
    final requestId = _requestId;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final branch = await _activeBranch(watch: false);
      final next = await ref.read(productRepositoryProvider).getProducts(
        branchId: branch.id,
        page: current.page + 1,
        limit: current.limit,
      );
      if (requestId != _requestId) return null;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: next.page,
          total: next.total,
          limit: next.limit,
          loadingMore: false,
        ),
      );
      return null;
    } on AppFailure catch (error) {
      if (requestId == _requestId) {
        state = AsyncData(current.copyWith(loadingMore: false));
      }
      return error;
    } finally {
      if (requestId == _requestId) _loadingMore = false;
    }
  }
}

final catalogProvider =
    AsyncNotifierProvider<CatalogController, CatalogPageData>(
      CatalogController.new,
    );

class ProductDetailsController extends FamilyAsyncNotifier<Product, String> {
  @override
  Future<Product> build(String arg) {
    return ref.watch(productRepositoryProvider).getProduct(arg);
  }
}

final productDetailsProvider =
    AsyncNotifierProvider.family<ProductDetailsController, Product, String>(
      ProductDetailsController.new,
    );
