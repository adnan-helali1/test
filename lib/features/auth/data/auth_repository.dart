import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/core/network/json_readers.dart';
import 'package:e_smart/core/storage/token_store.dart';

class AuthSession {
  const AuthSession({this.email, this.fullName});

  final String? email;
  final String? fullName;

  String get label {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (email != null && email!.isNotEmpty) return email!;
    return '';
  }
}

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenController _tokens;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return _saveSession(response);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    required String locale,
    String? phone,
  }) async {
    final response = await _post('/auth/register', {
      'email': email,
      'password': password,
      'fullName': fullName,
      'locale': locale,
      'acceptTerms': true,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return _saveSession(response);
  }

  Future<void> forgotPassword({required String email}) {
    return _post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) {
    return _post('/auth/reset-password', {
      'token': token,
      'password': password,
    });
  }

  Future<AuthSession> me() async {
    try {
      final response = await _dio.get<dynamic>('/auth/me');
      final map = asStringKeyMap(response.data);
      if (map == null) throw const ServerFailure();
      final user = asStringKeyMap(map['user']) ?? map;
      final email = readOptionalString(user['email']);
      final fullName = readOptionalString(user['fullName']);
      return AuthSession(email: email, fullName: fullName);
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      return response.data;
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<AuthSession> _saveSession(dynamic data) async {
    final map = asStringKeyMap(data);
    if (map == null) throw const ServerFailure();
    final access = readOptionalString(map['accessToken']);
    final refresh = readOptionalString(map['refreshToken']);
    if (access == null || refresh == null) throw const ServerFailure();
    final user = asStringKeyMap(map['user']);
    final email = readOptionalString(user?['email']);
    final fullName = readOptionalString(user?['fullName']);
    await _tokens.save(
      access: access,
      refresh: refresh,
      email: email,
      fullName: fullName,
    );
    return AuthSession(email: email, fullName: fullName);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.read(tokenProvider.notifier),
  );
});
