import 'package:asman_toga/helper/prefs.dart';
import 'package:flutter/material.dart';
import 'package:asman_toga/models/user.dart';
import 'package:asman_toga/service/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getProfile();
      _user = data;
    } catch (e) {
      debugPrint("Error loadProfile: $e");
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await ApiService.logout();

      if (success) {
        await PrefsHelper.clearToken();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        debugPrint("Logout gagal dari server");
        // opsional: bisa kasih snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logout gagal, coba lagi")),
        );
      }
    } catch (e) {
      debugPrint("Error logout: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }

    _isLoading = false;
    notifyListeners();
  }
}
