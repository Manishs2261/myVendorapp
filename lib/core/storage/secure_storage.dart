import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);
  Future<void> delete(String key) => _storage.delete(key: key);
}
