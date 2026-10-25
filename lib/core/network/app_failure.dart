import 'package:dio/dio.dart';

sealed class AppFailure implements Exception {
  const AppFailure();
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure();
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure();
}

final class ServerFailure extends AppFailure {
  const ServerFailure();
}

final class AiNotConfiguredFailure extends AppFailure {
  const AiNotConfiguredFailure();
}

final class AiUnavailableFailure extends AppFailure {
  const AiUnavailableFailure();
}

AppFailure mapDio(DioException error) {
  final status = error.response?.statusCode;
  if (status == 401) return const UnauthorizedFailure();
  if (status == 409) return const ConflictFailure();
  if (status == 503) {
    final data = error.response?.data;
    final code = data is Map ? data['code']?.toString() : null;
    if (code == 'AI_NOT_CONFIGURED') return const AiNotConfiguredFailure();
    if (code == 'AI_UNAVAILABLE') return const AiUnavailableFailure();
    return const ServerFailure();
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const TimeoutFailure(),
    DioExceptionType.connectionError => const NetworkFailure(),
    _ => status != null && status >= 500
        ? const ServerFailure()
        : const NetworkFailure(),
  };
}
