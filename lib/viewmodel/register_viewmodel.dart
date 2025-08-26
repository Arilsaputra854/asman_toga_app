import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  // State
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  // Register function
  Future<bool> register({name, email, password, confirmPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;

    if (result["success"]) {
      notifyListeners();
      return true; // berhasil
    } else {
      _errorMessage = result["message"];
      notifyListeners();
      return false;
    }
  }

}
