import 'dart:io';

import 'package:asman_toga/models/plants.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TambahLokasiTanamanViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingPlants = false;
  bool get isLoadingPlants => _isLoadingPlants;

  List<Plant> _plants = [];
  List<Plant> get plants => _plants;

  /// ambil semua tanaman dari API
  Future<void> getAllPlants() async {
    _isLoadingPlants = true;
    notifyListeners();
    try {
      final data = await ApiService.getPlants(); // API harus ada
      
      _plants = data;
    } catch (e) {
      _plants = [];
    }
    _isLoadingPlants = false;
    notifyListeners();
  }

  /// submit tanaman baru dengan foto (multipart)
  Future<bool> submitPlant({
    required int plantId,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
    List<XFile>? images,
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
        //images: images?.map((e) => File(e.path)).toList(),
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
