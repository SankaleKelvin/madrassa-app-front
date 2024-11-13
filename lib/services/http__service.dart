// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'shared_preferences_service.dart';
// import 'local_storage_service.dart';

// class HttpService {
//   static Future<http.Response> get(String url) async {
//     final token = kIsWeb
//         ? LocalStorageService.getToken()
//         : await SharedPreferencesService.getToken();

//     final headers = {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };

//     final response = await http.get(Uri.parse(url), headers: headers);
//     return response;
//   }

//   static Future<http.Response> post(String url, dynamic body) async {
//     final token = kIsWeb
//         ? LocalStorageService.getToken()
//         : await SharedPreferencesService.getToken();

//     final headers = {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };

//     final response = await http.post(
//       Uri.parse(url),
//       headers: headers,
//       body: jsonEncode(body),
//     );
//     return response;
//   }
// }