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
  required List<XFile> images,
}) async {
  try {
    _isLoading = true;
    notifyListeners();

    // 🔹 STEP 1: Upload foto sekali (multiple)
    final imageUrls = await ApiService.uploadUserPlantPhotos(images: images);

    // 🔹 STEP 2: Simpan data plant + list foto
    final result = await ApiService.addUserPlant(
      plantId: plantId,
      address: address,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      images: imageUrls,
    );

    return result != null;
  } catch (e) {
    debugPrint("❌ submitPlant error: $e");
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<bool> updatePlant({
  required String id,
  required String address,
  double? latitude,
  double? longitude,
  String? notes,
  required List<XFile> images,
}) async {
  try {
    _isLoading = true;
    notifyListeners();

    // 🔹 STEP 1: Upload foto baru (kalau ada)
    List<String> imageUrls = [];
    if (images.isNotEmpty) {
      imageUrls = await ApiService.uploadUserPlantPhotos(images: images);
    }

    // 🔹 STEP 2: Panggil API update tanaman
    final result = await ApiService.updateUserPlant(
      id: id,
      address: address,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      images: imageUrls,
    );

    return result != null;
  } catch (e) {
    debugPrint("❌ updatePlant error: $e");
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}
