import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/core/network/json_readers.dart';

class AuthenticityResult {
  const AuthenticityResult({
    this.message,
    this.valid,
    this.firstScan,
    this.productName,
    this.certificateNo,
    this.scannedAt,
    this.notFound = false,
  });

  final String? message;
  final bool? valid;
  final bool? firstScan;
  final String? productName;
  final String? certificateNo;
  final String? scannedAt;
  final bool notFound;
}

class AuthenticityRepository {
  AuthenticityRepository(this._dio);

  final Dio _dio;

  Future<AuthenticityResult> verify(String token) async {
    try {
      final response = await _dio.get<dynamic>(
        '/authenticity/verify/${Uri.encodeComponent(token)}',
      );
      final map = asStringKeyMap(response.data);
      if (map == null) {
        return const AuthenticityResult();
      }
      return AuthenticityResult(
        message: readOptionalString(map['message']),
        valid: _optionalBool(map['valid'] ?? map['isValid']),
        firstScan: _optionalBool(map['firstScan'] ?? map['isFirstScan']),
        productName: readOptionalString(map['productName'] ?? map['product']),
        certificateNo: readOptionalString(map['certificateNo']),
        scannedAt: readOptionalString(map['scannedAt']),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        final map = asStringKeyMap(error.response?.data);
        return AuthenticityResult(
          notFound: true,
          message: readOptionalString(map?['message']),
        );
      }
      throw mapDio(error);
    }
  }

  bool? _optionalBool(dynamic value) {
    if (value is bool) return value;
    return null;
  }
}

final authenticityRepositoryProvider = Provider<AuthenticityRepository>((ref) {
  return AuthenticityRepository(ref.watch(dioProvider));
});
