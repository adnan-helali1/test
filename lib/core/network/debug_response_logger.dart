import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prints response and error bodies in debug. Tokens and passwords are redacted.
class DebugResponseLogger extends Interceptor {
  static const redacted = '***';

  static const _secretKeys = {
    'accesstoken',
    'refreshtoken',
    'password',
    'otp',
    'resettoken',
    'authorization',
  };

  static const _chunk = 800;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _print(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      _print(response);
    } else {
      debugPrint(
        '┌ ERROR ${err.requestOptions.method} ${err.requestOptions.uri}\n'
        '${err.type} ${err.message}\n'
        '└ END ERROR',
      );
    }
    handler.next(err);
  }

  void _print(Response<dynamic> response) {
    final options = response.requestOptions;
    final body = _format(_redact(response.data));
    _write(
      '┌ RESPONSE ${options.method} ${response.statusCode} ${options.uri}\n'
      '$body\n'
      '└ END RESPONSE',
    );
  }

  Object? _redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: _secretKeys.contains('${entry.key}'.toLowerCase())
              ? redacted
              : _redact(entry.value),
      };
    }
    if (value is List) {
      return [for (final item in value) _redact(item)];
    }
    return value;
  }

  String _format(Object? value) {
    if (value == null) return 'null';
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on Object {
      return '$value';
    }
  }

  void _write(String text) {
    for (final line in text.split('\n')) {
      if (line.length <= _chunk) {
        debugPrint(line);
        continue;
      }
      for (var start = 0; start < line.length; start += _chunk) {
        final end = start + _chunk > line.length ? line.length : start + _chunk;
        debugPrint(line.substring(start, end));
      }
    }
  }
}
