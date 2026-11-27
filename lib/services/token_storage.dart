import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  static const _key = 'rusunawa_api_token';

  String? _sessionToken;

  Future<String?> read() async {
    return _sessionToken ?? await _storage.read(key: _key);
  }

  Future<void> save(
      String token, {
        bool rememberMe = true,
      }) async {
    if (rememberMe) {
      await _storage.write(key: _key, value: token);
    } else {
      await _storage.delete(key: _key);
    }

    _sessionToken = token;
  }

  Future<void> clear() async {
    _sessionToken = null;
    await _storage.delete(key: _key);
  }
}