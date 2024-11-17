// auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['token'], data['user']);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['token'], data['user']);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  static Future<void> _saveAuthData(
      String token, Map<String, dynamic> user) async {
    if (kIsWeb) {
      html.window.localStorage['token'] = token;
      html.window.localStorage['user'] = jsonEncode(user);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user));
    }
  }

  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } finally {
      await _clearAuthData();
    }
  }

  static Future<void> _clearAuthData() async {
    if (kIsWeb) {
      html.window.localStorage.remove('token');
      html.window.localStorage.remove('user');
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['token'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    if (kIsWeb) {
      final userStr = html.window.localStorage['user'];      
      return userStr != null ? jsonDecode(userStr) : null;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      return userStr != null ? jsonDecode(userStr) : null;
    }
  }

  static Future<bool> hasRole(String roleName) async {
    final user = await getCurrentUser();
    return user?['role']?['name']?.toLowerCase() == roleName.toLowerCase();
  }

  static Future<bool> hasAnyRole(List<String> roles) async {
    try {
      final user = await getCurrentUser();
      if (user == null || user['role'] == null) {
        return false;
      }
      final userRole = user?['role']?['slug']?.toLowerCase() ?? '';
      // return roles.map((r) => r.toLowerCase()).contains(userRole);
      print('checking roles: $userRole');
      print('checking Anyroles: $roles');
      return roles.any((role) => role.toLowerCase() == userRole.toLowerCase());
    } catch (e) {
      print('Error checking roles: $e');
      return false;
    }
  }

  static Future<List<String>> getUserRoles() async {
    try {
      String? userString;

      // Get stored user data
      if (kIsWeb) {
        userString = html.window.localStorage['user'];
      } else {
        final prefs = await SharedPreferences.getInstance();
        userString = prefs.getString('user');
      }

      if (userString == null) return [];

      // Parse the user data
      final Map<String, dynamic> userData = jsonDecode(userString);

      // Access the role from the user data structure
      // Assuming the structure is: {"role": {"name": "Admin"}}
      if (userData.containsKey('role') && userData['role'] is Map) {
        final roleName = userData['role']['slug']?.toString();
        print('>>>>>User is: $roleName');
        return roleName != null ? [roleName] : [];
      }

      return [];
    } catch (e) {
      print('Error getting user roles: $e');
      return [];
    }
  }
  // static Future<String?> getUserRoles() async {
  //   try {
  //     final userData = await getCurrentUser();
  //     if (userData != null && userData['role'] != null) {
  //       return userData['role']['name']?.toString();
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error getting user role: $e');
  //     return null;
  //   }
  // }
}
