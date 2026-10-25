import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/core/network/json_readers.dart';
import 'package:e_smart/core/format/localized_text.dart';

class CheckoutResult {
  const CheckoutResult({required this.id, this.orderNumber});

  final String id;
  final String? orderNumber;
}

class CouponQuote {
  const CouponQuote({required this.discountMinor, required this.valid});

  final int discountMinor;
  final bool valid;
}

class CartRepository {
  CartRepository(this._dio);

  final Dio _dio;

  static final _couponRe = RegExp(r'^[A-Z0-9_-]{3,50}$');

  Future<void> clearCart(String branchId) async {
    try {
      await _dio.delete<dynamic>(
        '/cart',
        queryParameters: {'branchId': branchId},
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<void> addItem({
    required String branchId,
    required String productId,
    required int quantity,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/cart/items',
        data: {
          'branchId': branchId,
          'productId': productId,
          'quantity': quantity,
        },
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<void> updateItem({
    required String branchId,
    required String productId,
    required int quantity,
  }) async {
    try {
      await _dio.patch<dynamic>(
        '/cart/items/$productId',
        queryParameters: {'branchId': branchId},
        data: {'quantity': quantity},
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<void> removeItem({
    required String branchId,
    required String productId,
  }) async {
    try {
      await _dio.delete<dynamic>(
        '/cart/items/$productId',
        queryParameters: {'branchId': branchId},
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<CouponQuote> quoteCoupon({
    required String branchId,
    required String code,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (!_couponRe.hasMatch(normalized)) {
      return const CouponQuote(discountMinor: 0, valid: false);
    }
    try {
      final response = await _dio.post<dynamic>(
        '/cart/coupon-quote/$branchId/$normalized',
      );
      final map = asStringKeyMap(response.data);
      final discountMinor = readOptionalInt(map?['discountMinor']);
      if (discountMinor != null) {
        return CouponQuote(discountMinor: discountMinor, valid: true);
      }
      final discount = readOptionalDouble(map?['discount']);
      if (discount != null) {
        return CouponQuote(discountMinor: discount.round(), valid: true);
      }
      return const CouponQuote(discountMinor: 0, valid: false);
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<CheckoutResult> checkout({
    required String branchId,
    required String addressId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/cart/checkout',
        data: {
          'branchId': branchId,
          'addressId': addressId,
          'paymentMethod': paymentMethod,
          if (couponCode != null && couponCode.isNotEmpty)
            'couponCode': couponCode.trim().toUpperCase(),
        },
      );
      final map = asStringKeyMap(response.data);
      if (map == null) throw const ServerFailure();
      final id = readOptionalString(map['id']);
      if (id == null) throw const ServerFailure();
      return CheckoutResult(
        id: id,
        orderNumber: readOptionalString(map['orderNumber']),
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  /// Sync local lines to the server cart before checkout.
  Future<void> syncLocalLines({
    required String branchId,
    required List<({String productId, int quantity})> lines,
  }) async {
    await clearCart(branchId);
    for (final line in lines) {
      await addItem(
        branchId: branchId,
        productId: line.productId,
        quantity: line.quantity,
      );
    }
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.watch(dioProvider));
});
