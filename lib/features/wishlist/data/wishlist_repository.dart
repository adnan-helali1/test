import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/core/network/json_readers.dart';

class WishlistRepository {
  WishlistRepository(this._dio);

  final Dio _dio;

  Future<List<String>> listIds() async {
    try {
      final response = await _dio.get<dynamic>('/users/me/wishlist');
      final ids = <String>[];
      for (final map in readListOrItems(response.data)) {
        final id = _productIdOf(map);
        if (id != null) ids.add(id);
      }
      return ids;
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<void> add(String productId) async {
    try {
      await _dio.post<dynamic>('/users/me/wishlist/$productId');
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<void> remove(String productId) async {
    try {
      await _dio.delete<dynamic>('/users/me/wishlist/$productId');
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  String? _productIdOf(Map<String, dynamic> map) {
    final direct = readOptionalString(map['productId']) ??
        readOptionalString(map['product_id']);
    if (direct != null) return direct;
    final product = asStringKeyMap(map['product']);
    final nested = readOptionalString(product?['id']);
    if (nested != null) return nested;
    return readOptionalString(map['id']);
  }
}

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(dioProvider));
});
