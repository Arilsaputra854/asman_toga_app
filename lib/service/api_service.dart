import 'dart:convert';
import 'dart:io';
import 'package:asman_toga/helper/prefs.dart';
import 'package:asman_toga/models/banjar.dart';
import 'package:asman_toga/models/plant_details.dart';
import 'package:asman_toga/models/plants.dart';
import 'package:asman_toga/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

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

  // GET ALL BANJAR (dengan model)
  static Future<List<Banjar>> getAllBanjarModel() async {
    final url = Uri.parse("$baseUrl/all-banjar");
    try {
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> list = json['banjars'] ?? [];
        return list.map((e) => Banjar.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // REGISTER dengan banjar_id
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required int banjarId,
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
          "banjar_id": banjarId,
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
        body: jsonEncode({"email": email, "password": password}),
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

      return {"success": response.statusCode == 200, "message": response.body};
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

      return {"success": response.statusCode == 200, "message": response.body};
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

      debugPrint(
        "⚠️ [getPlants] Gagal ambil data, status: ${response.statusCode}",
      );
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
  List<String>? images, // <--- tambahin parameter baru
}) async {
  final url = Uri.parse("$baseUrl/userplants");
  try {
    final headers = await _headers(withAuth: true);
    final body = {
      "plant_id": plantId,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "notes": notes,
      "images": images ?? [],
    };

    // 🔹 Debug request
    debugPrint("🌱 [addUserPlant] URL: $url");
    debugPrint("🌱 [addUserPlant] Headers: $headers");
    debugPrint("🌱 [addUserPlant] Body: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    // 🔹 Debug response
    debugPrint("🌱 [addUserPlant] Status: ${response.statusCode}");
    debugPrint("🌱 [addUserPlant] Response: ${response.body}");

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  } catch (e) {
    debugPrint("❌ [addUserPlant] Error: $e");
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
    List<String>? images,
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
          "images": images ?? [],
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

  static Future<Map<String, dynamic>?> getUserPlantByPlantId(
    int plantId,
  ) async {
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

  // ==================== UPLOAD USER PLANT ====================
  static Future<List<String>> uploadUserPlantPhotos({
  required List<XFile> images,
}) async {
  final url = Uri.parse("$baseUrl/upload");

  try {
    final token = await PrefsHelper.getToken();
    final request = http.MultipartRequest("POST", url);

    if (token != null) {
      request.headers["Authorization"] = "Bearer $token";
    }

    // 🔹 Tambah semua foto dengan key "files"
    for (var img in images) {
      debugPrint("📂 Uploading: ${img.path}");
      request.files.add(
        await http.MultipartFile.fromPath("files", img.path),
      );
    }

    debugPrint("📦 Jumlah file di-request: ${request.files.length}");

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(respStr);
      final List<dynamic> urls = data["urls"] ?? [];
      return urls.map((e) => e.toString()).toList();
    } else {
      debugPrint("⚠️ Upload gagal: ${response.statusCode}, $respStr");
      return [];
    }
  } catch (e) {
    debugPrint("❌ [uploadUserPlantPhotos] Error: $e");
    return [];
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

    // ==================== ADMIN ====================

  // ✅ Approve User Plant
  static Future<Map<String, dynamic>?> approveUserPlant(String id) async {
    final url = Uri.parse("$baseUrl/admin/$id/approve");
    try {
      final response = await http.put(
        url,
        headers: await _headers(withAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Decline User Plant
  static Future<Map<String, dynamic>?> declineUserPlant(String id) async {
    final url = Uri.parse("$baseUrl/admin/userplants/$id");
    try {
      final response = await http.delete(
        url,
        headers: await _headers(withAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Get All UserPlants (Admin version)
  static Future<List<dynamic>> getAllUserPlantsAdmin() async {
    final url = Uri.parse("$baseUrl/admin/userplants");
    try {
      final response = await http.get(
        url,
        headers: await _headers(withAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ✅ Get All Users (Admin version)
  static Future<List<dynamic>> getAllUsers() async {
    final url = Uri.parse("$baseUrl/admin/users");
    try {
      final response = await http.get(
        url,
        headers: await _headers(withAuth: true),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

}
