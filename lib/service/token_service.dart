import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final accessTokenKey = 'accessToken';
  final storage = FlutterSecureStorage();
  Future<void> saveAccessToken(String accessToken) async {
    await storage.write(key: accessTokenKey, value: accessToken);
    

  }
  Future<String?> getAccessToken() async {
    final token = await storage.read(key: accessTokenKey);
    log("Token: $token");
    return token;
  }
  Future<void> deleteAccessToken() async {
    await storage.delete(key: accessTokenKey);
  }
}