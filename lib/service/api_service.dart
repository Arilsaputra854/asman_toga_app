import 'dart:convert';
import 'package:asman_toga/helper/prefs.dart';
import 'package:asman_toga/models/plant_details.dart';
import 'package:asman_toga/models/plants.dart';
import 'package:asman_toga/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl =
      "https://asman-toga-production.up.railway.app/api/v1";

  // 🔹 Helper buat header
  static Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = {"Content-Type": "application/json"};
    if (withAuth) {
      final token = await PrefsHelper.getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  // ==================== AUTH ====================

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String role = "user",
  }) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
          "role": role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
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
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await PrefsHelper.saveToken(data['token']); // simpan token
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // FORGOT PASSWORD
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse("$baseUrl/forgot-password");
    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({"email": email}),
      );

      return {
        "success": response.statusCode == 200,
        "message": response.body,
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse("$baseUrl/reset-password");
    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          "token": token,
          "new_password": newPassword,
          "confirm_password": confirmPassword,
        }),
      );

      return {
        "success": response.statusCode == 200,
        "message": response.body,
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // PROFILE
  static Future<User?> getProfile() async {
  final url = Uri.parse("$baseUrl/profile");

  try {
    final response = await http.get(
      url,
      headers: await _headers(withAuth: true),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User.fromJson(json['user']); // ✅ ambil dari key "user"
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}


  // LOGOUT
  static Future<bool> logout() async {
    final url = Uri.parse("$baseUrl/logout");

    try {
      final response = await http.post(
        url,
        headers: await _headers(withAuth: true),
      );

      if (response.statusCode == 200) {
        await PrefsHelper.clearToken();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== PLANTS ====================

  static Future<List<Plant>> getPlants() async {
  final url = Uri.parse("$baseUrl/plants");
  try {
    debugPrint("🔍 [getPlants] Request ke: $url");
    final headers = await _headers();
    debugPrint("📩 [getPlants] Headers: $headers");

    final response = await http.get(url, headers: headers);
    debugPrint("📡 [getPlants] Status Code: ${response.statusCode}");
    debugPrint("📦 [getPlants] Body: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      debugPrint("✅ [getPlants] JSON Decode: $json");

      final List<dynamic> plantList = json['plants'] ?? [];
      debugPrint("🌱 [getPlants] Jumlah tanaman: ${plantList.length}");

      return plantList.map((e) => Plant.fromJson(e)).toList();
    }

    debugPrint("⚠️ [getPlants] Gagal ambil data, status: ${response.statusCode}");
    return [];
  } catch (e, stack) {
    debugPrint("❌ [getPlants] Error: $e");
    debugPrint("📝 Stacktrace: $stack");
    return [];
  }
}



  static Future<PlantDetails?> getPlantDetail(String slug) async {
  final url = Uri.parse("$baseUrl/plants/$slug");
  try {
    final response = await http.get(url, headers: await _headers());
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PlantDetails.fromJson(json['plant']); // ✅ parsing langsung
    }
    return null;
  } catch (e) {
    return null;
  }
}


  // ==================== USER PLANTS ====================

  static Future<List<dynamic>> getUserPlants() async {
    final url = Uri.parse("$baseUrl/userplants");
    try {
      final response = await http.get(url, headers: await _headers());
      debugPrint("RESPONSE USER PLANTS :${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> addUserPlant({
    required int plantId,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final url = Uri.parse("$baseUrl/userplants");
    try {
      final response = await http.post(
        url,
        headers: await _headers(withAuth: true),
        body: jsonEncode({
          "plant_id": plantId,
          "address": address,
          "latitude": latitude,
          "longitude": longitude,
          "notes": notes,
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserPlantById(String id) async {
    final url = Uri.parse("$baseUrl/userplants/$id");
    try {
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateUserPlant({
    required String id,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final url = Uri.parse("$baseUrl/userplants/$id");
    try {
      final response = await http.put(
        url,
        headers: await _headers(withAuth: true),
        body: jsonEncode({
          "address": address,
          "latitude": latitude,
          "longitude": longitude,
          "notes": notes,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> approveUserPlant(String id) async {
    final url = Uri.parse("$baseUrl/$id/approve");
    try {
      final response =
          await http.put(url, headers: await _headers(withAuth: true));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserPlantByPlantId(
      int plantId) async {
    final url = Uri.parse("$baseUrl/userplants/by-plant/$plantId");
    try {
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== BANJAR ====================

  static Future<List<dynamic>> getAllBanjar() async {
    final url = Uri.parse("$baseUrl/all-banjar");
    try {
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['banjars'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
