import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

List<int> getEncryptKey(String encryptionKey) {
  String key = encryptionKey;
  while (key.length < 32) {
    key = 'k$key';
  }
  return utf8.encode(key);
}

class Preferences {
  static FlutterSecureStorage storage = const FlutterSecureStorage();

  static Future<void> addItem(String key, dynamic value) async {
    await storage.write(key: key, value: value);
  }

  static Future<String?> getItem(String key) async {
    return await storage.read(key: key);
  }
}
