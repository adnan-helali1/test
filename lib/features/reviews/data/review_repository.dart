import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/features/reviews/data/review.dart';

class ReviewRepository {
  ReviewRepository(this._dio);

  final Dio _dio;

  Future<ReviewPageData> getReviews({
    required String productId,
    required int page,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/products/$productId/reviews',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data is! Map) throw const ServerFailure();
      return ReviewPageData.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    } on AppFailure {
      rethrow;
    } on DioException catch (error) {
      throw mapDio(error);
    } on FormatException {
      throw const ServerFailure();
    }
  }

  Future<void> createReview({
    required String productId,
    required int rating,
    String? text,
    String? displayName,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/products/$productId/reviews',
        data: {
          'rating': rating,
          if (text != null && text.isNotEmpty) 'text': text,
          if (displayName != null && displayName.isNotEmpty)
            'displayName': displayName,
        },
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(dioProvider));
});
