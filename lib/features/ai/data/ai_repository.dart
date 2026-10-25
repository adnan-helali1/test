import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/features/ai/data/ai_models.dart';

class AiRepository {
  AiRepository(this._dio);

  final Dio _dio;

  Future<AiStatus> status() async {
    try {
      final response = await _dio.get<dynamic>('/ai/status');
      final data = response.data;
      if (data is! Map) throw const ServerFailure();
      return AiStatus.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<AiSearchResult> search({
    required String branchId,
    required String query,
    required String locale,
    List<AiChatTurn> history = const [],
  }) {
    return _post(
      '/ai/search',
      branchId: branchId,
      query: query,
      locale: locale,
      history: null,
    );
  }

  Future<AiSearchResult> assistant({
    required String branchId,
    required String query,
    required String locale,
    required List<AiChatTurn> history,
  }) {
    return _post(
      '/ai/assistant',
      branchId: branchId,
      query: query,
      locale: locale,
      history: history,
    );
  }

  Future<AiSearchResult> _post(
    String path, {
    required String branchId,
    required String query,
    required String locale,
    required List<AiChatTurn>? history,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: {
          'branchId': branchId,
          'query': query,
          'locale': locale,
          'limit': 8,
          if (history != null)
            'history': [
              for (final turn in history) turn.toJson(),
            ],
        },
      );
      final data = response.data;
      if (data is! Map) throw const ServerFailure();
      return AiSearchResult.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioProvider));
});
