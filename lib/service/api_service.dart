import 'dart:convert';
import 'package:asman_toga/helper/prefs.dart';
import 'package:asman_toga/models/user.dart';
import 'package:flutter/foundation.dart'; // supaya bisa pakai debugPrint
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://asman-toga-production.up.railway.app/api/v1";

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      debugPrint("➡️ [REGISTER] POST $url");
      debugPrint("📦 Body: ${{
        "name": name,
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
      }}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      debugPrint("⬅️ [REGISTER] Status: ${response.statusCode}");
      debugPrint("⬅️ [REGISTER] Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      debugPrint("❌ [REGISTER] Error: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      debugPrint("➡️ [LOGIN] POST $url");
      debugPrint("📦 Body: ${{
        "email": email,
        "password": password,
      }}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      debugPrint("⬅️ [LOGIN] Status: ${response.statusCode}");
      debugPrint("⬅️ [LOGIN] Response: ${response.body}");

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      debugPrint("❌ [LOGIN] Error: $e");
      return {"success": false, "message": e.toString()};
    }
  }

   // PROFILE
  static Future<User?> getProfile() async {
    final url = Uri.parse("$baseUrl/profile");
    final token = await PrefsHelper.getToken();

    if (token == null) {
      debugPrint("❌ [PROFILE] Token not found");
      return null;
    }

    try {
      debugPrint("➡️ [PROFILE] GET $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("⬅️ [PROFILE] ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User.fromJson(json['user']);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("❌ [PROFILE] Error: $e");
      return null;
    }
  }
}
