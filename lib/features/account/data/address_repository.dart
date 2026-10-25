import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/core/network/json_readers.dart';
import 'package:e_smart/features/account/data/address.dart';

class AddressRepository {
  AddressRepository(this._dio);

  final Dio _dio;

  Future<List<Address>> list() async {
    try {
      final response = await _dio.get<dynamic>('/users/me/addresses');
      return [
        for (final map in readListOrItems(response.data)) Address.fromJson(map),
      ];
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<String> create({
    required String label,
    required String recipientName,
    required String phone,
    required String city,
    required String details,
    String country = 'SA',
    String? postalCode,
    bool isDefault = true,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/users/me/addresses',
        data: {
          'label': label,
          'recipientName': recipientName,
          'phone': phone,
          'country': country,
          'city': city,
          'details': details,
          'postalCode': postalCode,
          'isDefault': isDefault,
        },
      );
      final map = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : null;
      final id = readOptionalString(map?['id']);
      if (id == null || id.isEmpty) {
        throw const ServerFailure();
      }
      return id;
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }
}

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(dioProvider));
});
