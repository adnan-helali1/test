import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/debug_response_logger.dart';
import 'package:e_smart/core/network/json_readers.dart';
import 'package:e_smart/core/storage/locale_preference.dart';
import 'package:e_smart/core/storage/token_store.dart';

const apiBaseUrl = 'https://e-smart.nmo.marketing/api/v1';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );

  Future<bool>? refreshInFlight;

  Future<bool> refreshOnce(String refreshToken) {
    final existing = refreshInFlight;
    if (existing != null) return existing;
    final future = _exchangeRefreshToken(ref, refreshToken);
    refreshInFlight = future;
    return future.whenComplete(() {
      if (identical(refreshInFlight, future)) refreshInFlight = null;
    });
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final language = ref.read(localeProvider).languageCode;
        options.headers['Accept'] = 'application/json';
        options.headers['Accept-Language'] = language;
        final access = ref.read(tokenProvider).access;
        if (access != null && options.extra['skipAuth'] != true) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final options = error.requestOptions;
        final path = options.uri.path;
        final credentialCall = path.endsWith('/auth/login') ||
            path.endsWith('/auth/register') ||
            path.endsWith('/auth/forgot-password') ||
            path.endsWith('/auth/reset-password') ||
            path.endsWith('/auth/refresh');
        final retried = options.extra['retried'] == true;
        if (status != 401 || credentialCall) {
          handler.next(error);
          return;
        }

        final refreshToken = ref.read(tokenProvider).refresh;
        if (refreshToken == null || retried) {
          await ref.read(tokenProvider.notifier).clear();
          handler.next(error);
          return;
        }

        final refreshed = await refreshOnce(refreshToken);
        if (!refreshed) {
          await ref.read(tokenProvider.notifier).clear();
          handler.next(error);
          return;
        }

        try {
          options.extra['retried'] = true;
          final access = ref.read(tokenProvider).access;
          if (access != null) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          final response = await dio.fetch<dynamic>(options);
          handler.resolve(response);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  if (kDebugMode) {
    // Path/status from PrettyDioLogger. Full bodies (including errors) from
    // DebugResponseLogger with tokens and passwords redacted.
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        compact: true,
      ),
    );
    dio.interceptors.add(DebugResponseLogger());
  }

  ref.onDispose(dio.close);
  return dio;
});

/// Refresh uses a second client so a 401 cannot re-enter the auth interceptor.
Future<bool> _exchangeRefreshToken(Ref ref, String refreshToken) async {
  final language = ref.read(localeProvider).languageCode;
  final client = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Accept-Language': language,
      },
    ),
  );
  try {
    if (kDebugMode) debugPrint('POST /auth/refresh');
    final response = await client.post<dynamic>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final map = asStringKeyMap(response.data);
    final access = readOptionalString(map?['accessToken']);
    final nextRefresh = readOptionalString(map?['refreshToken']) ?? refreshToken;
    if (access == null) return false;
    final current = ref.read(tokenProvider);
    await ref.read(tokenProvider.notifier).save(
      access: access,
      refresh: nextRefresh,
      email: current.email,
      fullName: current.fullName,
    );
    return true;
  } catch (_) {
    return false;
  } finally {
    client.close();
  }
}
