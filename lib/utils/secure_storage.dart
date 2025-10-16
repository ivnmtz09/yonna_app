import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> saveRefresh(String refresh) async {
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<String?> getRefresh() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
