import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/core/network/json_readers.dart';
import 'package:e_smart/features/account/data/order.dart';

class OrderRepository {
  OrderRepository(this._dio);

  final Dio _dio;

  Future<List<StoreOrder>> list() async {
    try {
      final response = await _dio.get<dynamic>('/orders');
      return [
        for (final map in readListOrItems(response.data))
          StoreOrder.fromJson(map),
      ];
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<StoreOrder> getById(String id) async {
    try {
      final response = await _dio.get<dynamic>('/orders/$id');
      final map = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : null;
      if (map == null) throw const ServerFailure();
      return StoreOrder.fromJson(map);
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(dioProvider));
});
