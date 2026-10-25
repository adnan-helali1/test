import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/features/products/data/product.dart';

class ProductRepository {
  ProductRepository(this._dio);

  final Dio _dio;

  Future<CatalogPageData> getProducts({
    required String branchId,
    required int page,
    int limit = catalogPageSize,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/products',
        queryParameters: {
          'branchId': branchId,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is! Map) throw const ServerFailure();
      return CatalogPageData.fromJson(
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

  Future<Product> getProduct(String id) async {
    try {
      final response = await _dio.get<dynamic>('/products/$id');
      final data = response.data;
      if (data is! Map) throw const ServerFailure();
      return Product.fromJson(
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
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});
