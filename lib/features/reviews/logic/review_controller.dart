import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/features/reviews/data/review.dart';
import 'package:e_smart/features/reviews/data/review_repository.dart';

class ReviewListController extends FamilyAsyncNotifier<ReviewPageData, String> {
  @override
  Future<ReviewPageData> build(String arg) {
    return ref.watch(reviewRepositoryProvider).getReviews(productId: arg, page: 1);
  }

  Future<AppFailure?> refresh() async {
    final previous = state.valueOrNull;
    try {
      final page = await ref.read(reviewRepositoryProvider).getReviews(
        productId: arg,
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
    if (current == null || !current.hasMore || current.loadingMore) return null;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref.read(reviewRepositoryProvider).getReviews(
        productId: arg,
        page: current.page + 1,
        limit: current.limit,
      );
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
      state = AsyncData(current.copyWith(loadingMore: false));
      return error;
    }
  }
}

final reviewListProvider =
    AsyncNotifierProvider.family<ReviewListController, ReviewPageData, String>(
      ReviewListController.new,
    );
