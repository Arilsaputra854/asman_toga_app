// login_view_model.dart
import 'package:asman_toga/helper/prefs.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.login(email: email, password: password);

    _isLoading = false;

    if (response["success"]) {
      _userData = response["data"];

      // ✅ Simpan token
      if (response["data"]["token"] != null) {
        await PrefsHelper.saveToken(response["data"]["token"]);
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false;
    }
  }
}
