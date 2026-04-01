import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String biometricEnabledKey = 'biometric_enabled';

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String name,
    required String email,
    required String role,
    required bool biometricEnabled,
  }) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
    await _storage.write(key: userNameKey, value: name);
    await _storage.write(key: userEmailKey, value: email);
    await _storage.write(key: userRoleKey, value: role);
    await _storage.write(
      key: biometricEnabledKey,
      value: biometricEnabled.toString(),
    );
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: refreshTokenKey);
  }

  Future<String?> readUserName() async {
    return _storage.read(key: userNameKey);
  }

  Future<String?> readUserEmail() async {
    return _storage.read(key: userEmailKey);
  }

  Future<String?> readUserRole() async {
    return _storage.read(key: userRoleKey);
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: biometricEnabledKey);
    return value == 'true';
  }

  Future<bool> hasStoredSession() async {
    final refreshToken = await readRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: userNameKey);
    await _storage.delete(key: userEmailKey);
    await _storage.delete(key: userRoleKey);
    await _storage.delete(key: biometricEnabledKey);
  }
}