import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/features/branches/data/branch.dart';

class BranchRepository {
  BranchRepository(this._dio);

  final Dio _dio;

  Future<List<Branch>> getBranches() async {
    try {
      final response = await _dio.get<dynamic>('/branches');
      final data = response.data;
      if (data is! List) throw const ServerFailure();
      return [
        for (final entry in data)
          if (asStringKeyMap(entry) != null)
            Branch.fromJson(asStringKeyMap(entry)!),
      ];
    } on AppFailure {
      rethrow;
    } on DioException catch (error) {
      throw mapDio(error);
    } on FormatException {
      throw const ServerFailure();
    }
  }
}

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository(ref.watch(dioProvider));
});
