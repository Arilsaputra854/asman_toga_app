import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';

class TambahLokasiTanamanViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> submitPlant({
    required int plantId,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.addUserPlant(
        plantId: plantId,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );

      _isLoading = false;
      notifyListeners();

      return result != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
