import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:asman_toga/models/user.dart';

class HomeViewModel extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await ApiService.getProfile();
      if (profile != null) {
        _user = profile;
      } else {
        _error = "Gagal mengambil data user";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
