import 'dart:convert';
import 'dart:html' as html;  // Only works on the web
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const _tokenKey = 'token';
  static const _userKey = 'user';

  /// Retrieves the token based on the platform.
  static Future<String?> getToken() async {
    try {
      final token = await _readToken();
      print('Retrieved token: $token');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Stores the token based on the platform.
  static Future<void> setToken(String token) async {
    try {
      await _writeToken(token);
      print('Stored token: $token');
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  /// Reads the token according to the platform
  static Future<String?> _readToken() async {
    if (kIsWeb) {
      // Web platform - use browser localStorage directly
      final storedToken = html.window.localStorage[_tokenKey];
      final storedUser = html.window.localStorage[_userKey];
      print('Read token from localStorage (web): $storedToken');
      print('Read User from localStorage (web): $storedUser');
      return storedToken;
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
      // Mobile platforms - use secure storage
      final storage = FlutterSecureStorage();
      final storedToken = await storage.read(key: _tokenKey);
      final storedUser = await storage.read(key: _userKey);
      print('Read token from secure storage (mobile): $storedToken');
      print('Read User from secure storage (mobile): $storedUser');
      return storedToken;
    } else {
      // Desktop platforms - use shared_preferences
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString(_tokenKey);
      final storedUser = prefs.getString(_userKey);
      print('Read token from shared_preferences (desktop): $storedToken');
      print('Read User from shared_preferences (desktop): $storedUser');
      return storedToken;
    }
  }

  /// Writes the token according to the platform
  static Future<void> _writeToken(String token) async {
    if (kIsWeb) {
      // Web platform - use browser localStorage directly
      html.window.localStorage[_tokenKey] = token;
      print('Stored token in localStorage (web): $token');
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
      // Mobile platforms - use secure storage
      final storage = FlutterSecureStorage();
      await storage.write(key: _tokenKey, value: token);
      print('Stored token in secure storage (mobile): $token');
    } else {
      // Desktop platforms - use shared_preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('Stored token in shared_preferences (desktop): $token');
    }
  }
}
