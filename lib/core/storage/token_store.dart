import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenSnapshot {
  const TokenSnapshot({
    this.access,
    this.refresh,
    this.email,
    this.fullName,
  });

  final String? access;
  final String? refresh;
  final String? email;
  final String? fullName;

  static const empty = TokenSnapshot();

  bool get isAuthenticated => access != null && access!.isNotEmpty;
}

class TokenController extends Notifier<TokenSnapshot> {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_full_name';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  TokenSnapshot build() => TokenSnapshot.empty;

  Future<void> restore() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      final email = await _storage.read(key: _emailKey);
      final fullName = await _storage.read(key: _nameKey);
      state = TokenSnapshot(
        access: _blankToNull(access),
        refresh: _blankToNull(refresh),
        email: _blankToNull(email),
        fullName: _blankToNull(fullName),
      );
    } catch (_) {
      state = TokenSnapshot.empty;
    }
  }

  Future<void> save({
    required String access,
    required String refresh,
    String? email,
    String? fullName,
  }) async {
    state = TokenSnapshot(
      access: access,
      refresh: refresh,
      email: _blankToNull(email),
      fullName: _blankToNull(fullName),
    );
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _writeOptional(_emailKey, email);
    await _writeOptional(_nameKey, fullName);
  }

  Future<void> clear() async {
    state = TokenSnapshot.empty;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _nameKey);
  }

  Future<void> _writeOptional(String key, String? value) async {
    final trimmed = _blankToNull(value);
    if (trimmed == null) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: trimmed);
    }
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

final tokenProvider = NotifierProvider<TokenController, TokenSnapshot>(
  TokenController.new,
);
