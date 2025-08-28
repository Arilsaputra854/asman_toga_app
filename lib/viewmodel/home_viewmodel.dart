import 'package:asman_toga/models/plants.dart';
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

  List<Plant> _plants = [];
  bool _isLoadingPlants = false;
  String? _plantsError;

  List<Plant> get plants => _plants;
  bool get isLoadingPlants => _isLoadingPlants;
  String? get plantsError => _plantsError;

  /// Fetch User Profile
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

  /// Fetch Plants
  Future<void> fetchPlants() async {
    _isLoadingPlants = true;
    _plantsError = null;
    notifyListeners();

    try {
      final data = await ApiService.getPlants();
      if (data != null) {
        _plants = data;
      } else {
        _plantsError = "Gagal mengambil data tanaman";
      }
    } catch (e) {
      _plantsError = e.toString();
    }

    _isLoadingPlants = false;
    notifyListeners();
  }
}
