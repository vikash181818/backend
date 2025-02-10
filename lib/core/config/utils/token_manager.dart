import 'dart:convert';

import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
//import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';

class TokenManager {
  static const tokenKey = "auth_token";
  static const userKey = "user_data";

  final SecureStorageService secureStorage;

  TokenManager(this.secureStorage);

  Future<void> saveToken(String token) async {
    await secureStorage.write(tokenKey, token);
  }

  Future<String?> getToken() async {
    return secureStorage.read(tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await secureStorage.write(userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final data = await secureStorage.read(userKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clear() async {
    await secureStorage.delete(tokenKey);
    await secureStorage.delete(userKey);
  }
}
