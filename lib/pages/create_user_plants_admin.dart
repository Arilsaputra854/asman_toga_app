import 'dart:io';

import 'package:asman_toga/pages/plants_tab.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:asman_toga/viewmodel/create_userplant_admin_viewmodel.dart';
import 'package:asman_toga/viewmodel/tambah_lokasi_tanaman_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class CreateUserPlantsAdmin extends StatefulWidget {
  final Map<String, dynamic>? existingPlant;
  const CreateUserPlantsAdmin({
    super.key,
    this.existingPlant, // opsional
  });

  @override
  State<CreateUserPlantsAdmin> createState() => _CreateUserPlantsAdminState();
}

// Polygon baru berdasarkan titik yang diberikan
final List<LatLng> desaGunaksaPolygon = [
  LatLng(-8.522987, 115.435086),
  LatLng(-8.524770, 115.439464),
  LatLng(-8.526807, 115.440322),
  LatLng(-8.531391, 115.437919),
  LatLng(-8.535635, 115.438262),
  LatLng(-8.538520, 115.438777),
  LatLng(-8.540133, 115.437661),
  LatLng(-8.542001, 115.438605),
  LatLng(-8.544717, 115.437061),
  LatLng(-8.547772, 115.434056),
  LatLng(-8.549724, 115.436717),
  LatLng(-8.552356, 115.442210),
  LatLng(-8.551422, 115.443412),
  LatLng(-8.551592, 115.445558),
  LatLng(-8.552016, 115.448218),
  LatLng(-8.558127, 115.448819),
  LatLng(-8.556430, 115.443498),
  LatLng(-8.561777, 115.443240),
  LatLng(-8.563899, 115.438863),
  LatLng(-8.572328, 115.440231),
  LatLng(-8.573419, 115.434159),
  LatLng(-8.571873, 115.429502),
  LatLng(-8.556666, 115.427189),
  LatLng(-8.549130, 115.419840),
  LatLng(-8.544689, 115.421201),
  LatLng(-8.539978, 115.421201),
  LatLng(-8.540248, 115.423514),
  LatLng(-8.537691, 115.424739),
  LatLng(-8.533916, 115.423646),
  LatLng(-8.530704, 115.427445),
  LatLng(-8.526028, 115.431811),
  LatLng(-8.524467, 115.434913),
];

// Fungsi cek point di polygon (ray-casting)
bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  int i, j = polygon.length - 1;
  bool oddNodes = false;

  for (i = 0; i < polygon.length; i++) {
    if ((polygon[i].latitude < point.latitude &&
                polygon[j].latitude >= point.latitude ||
            polygon[j].latitude < point.latitude &&
                polygon[i].latitude >= point.latitude) &&
        (polygon[i].longitude +
                (point.latitude - polygon[i].latitude) /
                    (polygon[j].latitude - polygon[i].latitude) *
                    (polygon[j].longitude - polygon[i].longitude) <
            point.longitude)) {
      oddNodes = !oddNodes;
    }
    j = i;
  }

  return oddNodes;
}

class _CreateUserPlantsAdminState extends State<CreateUserPlantsAdmin> {
  // Modern color palette
  static const Color primaryGreen = Color(0xFF57A32E);
  static const Color lightGreen = Color(0xFF7BC142);
  static const Color backgroundColor = Color(0xFFF8FAF6);
  static const Color cardColor = Colors.white;
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFFF8C42);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentBlue = Color(0xFF3182CE);

  List<Map<String, dynamic>> users = [];
  String? selectedUserId;
  bool isLoadingUsers = false;

  List<XFile> selectedImages = [];
  List<int> selectedPlantIds = [];
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  LatLng selectedLocation = LatLng(-8.544444, 115.423333); // Titik awal
  final mapController = MapController();

  Future<void> fetchUsers() async {
    setState(() => isLoadingUsers = true);
    try {
      final result = await ApiService.getAllUsers();
      setState(() {
        users = List<Map<String, dynamic>>.from(result);
        isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => isLoadingUsers = false);
      _showErrorSnackBar('Gagal memuat data pengguna: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    fetchUsers();

    if (widget.existingPlant != null) {
      final plant = widget.existingPlant!;
      namaController.text = plant["location"]["user"]["name"] ?? "";
      alamatController.text = plant["location"]["address"] ?? "";
      latController.text = plant["location"]["latitude"].toString();
      lngController.text = plant["location"]["longitude"].toString();
      catatanController.text = plant["notes"] ?? "";

      selectedLocation = LatLng(
        plant["location"]["latitude"],
        plant["location"]["longitude"],
      );

      selectedUserId = plant["location"]["user"]["id"];
    } else {
      latController.text = selectedLocation.latitude.toStringAsFixed(6);
      lngController.text = selectedLocation.longitude.toStringAsFixed(6);
    }

    context.read<CreateUserplantAdminViewmodel>().getAllPlants();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      List<XFile> validImages = [];

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mengompres gambar...',
                    style: TextStyle(color: textSecondary),
                  ),
                ],
              ),
            ),
      );

      for (var img in images) {
        final compressed = await compressImageUnder500KB(img);
        if (compressed != null) {
          validImages.add(compressed);
        } else {
          _showErrorSnackBar("${img.name} tidak bisa dikompres < 500KB");
        }
      }

      Navigator.of(context).pop(); // Close loading dialog

      if (validImages.isNotEmpty) {
        setState(() {
          selectedImages.addAll(validImages);
        });
        _showSuccessSnackBar(
          '${validImages.length} gambar berhasil ditambahkan',
        );
      }
    }
  }

  Future<void> goToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar("Aktifkan layanan lokasi");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar("Izin lokasi ditolak");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar("Izin lokasi ditolak permanen, buka pengaturan");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng current = LatLng(position.latitude, position.longitude);

      if (isPointInPolygon(current, desaGunaksaPolygon)) {
        setState(() {
          selectedLocation = current;
          latController.text = current.latitude.toStringAsFixed(6);
          lngController.text = current.longitude.toStringAsFixed(6);
        });
        mapController.move(current, 16);
        _showSuccessSnackBar("Lokasi berhasil diperbarui");
      } else {
        _showErrorSnackBar("Lokasi Anda di luar area yang diizinkan");
      }
    } catch (e) {
      _showErrorSnackBar("Gagal mendapatkan lokasi: $e");
    }
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? textPrimary : textSecondary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryGreen, size: 20),
          ),
          filled: true,
          fillColor: enabled ? cardColor : backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryGreen, width: 2),
          ),
          labelStyle: TextStyle(color: textSecondary, fontSize: 14),
          hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CreateUserplantAdminViewmodel>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        title: Text(
          widget.existingPlant == null
              ? "Tambah Lokasi Tanaman"
              : "Update Lokasi Tanaman",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_rounded, color: textPrimary),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Selection Section
            _buildSectionTitle("Informasi Pengguna", Icons.person_rounded),
            _buildModernCard(
              child: Column(
                children: [
                  isLoadingUsers
                      ? Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryGreen,
                              ),
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Memuat data pengguna...',
                              style: TextStyle(color: textSecondary),
                            ),
                          ],
                        ),
                      )
                      : DropdownButtonFormField<String>(
                        value: selectedUserId,
                        isExpanded: true,
                        style: TextStyle(color: textPrimary, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: "Pilih Pengguna",
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: primaryGreen,
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primaryGreen,
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        items:
                            users
                                .map(
                                  (u) => DropdownMenuItem<String>(
                                    value: u["id"].toString(),
                                    child: Text(u["name"] ?? "-"),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => selectedUserId = v),
                      ),
                ],
              ),
            ),

            // Location Information Section
            _buildSectionTitle("Informasi Lokasi", Icons.location_on_rounded),
            _buildModernCard(
              child: Column(
                children: [
                  _buildModernTextField(
                    controller: alamatController,
                    label: "Alamat Lengkap",
                    icon: Icons.home_rounded,
                    hint: "Masukkan alamat lokasi tanaman",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          controller: latController,
                          label: "Latitude",
                          icon: Icons.place_rounded,
                          keyboardType: TextInputType.number,
                          enabled: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernTextField(
                          controller: lngController,
                          label: "Longitude",
                          icon: Icons.place_rounded,
                          keyboardType: TextInputType.number,
                          enabled: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Map Section
            _buildSectionTitle("Pilih Lokasi di Peta", Icons.map_rounded),
            _buildModernCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        center: selectedLocation,
                        zoom: 16,
                        interactiveFlags: InteractiveFlag.all,
                        onTap: (pos, point) {
                          if (isPointInPolygon(point, desaGunaksaPolygon)) {
                            setState(() {
                              selectedLocation = point;
                              latController.text = point.latitude
                                  .toStringAsFixed(6);
                              lngController.text = point.longitude
                                  .toStringAsFixed(6);
                            });
                            _showSuccessSnackBar("Lokasi berhasil dipilih");
                          } else {
                            _showErrorSnackBar(
                              "Lokasi di luar area yang diizinkan",
                            );
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: [
                                LatLng(-90, -180),
                                LatLng(-90, 180),
                                LatLng(90, 180),
                                LatLng(90, -180),
                              ],
                              holePointsList: [desaGunaksaPolygon],
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            Polygon(
                              points: desaGunaksaPolygon,
                              color: primaryGreen.withOpacity(0.1),
                              borderStrokeWidth: 2,
                              borderColor: primaryGreen,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation,
                              width: 50,
                              height: 50,
                              builder:
                                  (_) => Container(
                                    decoration: BoxDecoration(
                                      color: errorRed,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: errorRed.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: goToCurrentLocation,
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text("Gunakan Lokasi Saya"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Plants Selection Section
            _buildSectionTitle("Pilih Tanaman", Icons.eco_rounded),
            _buildModernCard(
              child:
                  vm.isLoading
                      ? Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryGreen,
                              ),
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Memuat data tanaman...',
                              style: TextStyle(color: textSecondary),
                            ),
                          ],
                        ),
                      )
                      : MultiSelectDialogField(
                        items:
                            vm.plants
                                .map((p) => MultiSelectItem<int>(p.id, p.name))
                                .toList(),
                        title: const Text("Pilih Tanaman"),
                        buttonText: const Text("Tambahkan Tanaman"),
                        listType: MultiSelectListType.CHIP,
                        searchable: true,
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryGreen.withOpacity(0.2),
                          ),
                        ),
                        buttonIcon: Icon(
                          Icons.eco_rounded,
                          color: primaryGreen,
                        ),
                        onConfirm:
                            (values) => setState(
                              () => selectedPlantIds = values.cast<int>(),
                            ),
                      ),
            ),

            // Notes Section
            _buildSectionTitle("Catatan Tambahan", Icons.note_rounded),
            _buildModernCard(
              child: _buildModernTextField(
                controller: catatanController,
                label: "Catatan (opsional)",
                icon: Icons.note_rounded,
                maxLines: 4,
                hint: "Tambahkan catatan atau informasi tambahan...",
              ),
            ),

            // Images Section
            _buildSectionTitle("Foto Tanaman", Icons.camera_alt_rounded),
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: pickImages,
                      icon: const Icon(Icons.add_photo_alternate_rounded),
                      label: const Text("Tambah Foto"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: warningOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  if (selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      '${selectedImages.length} foto dipilih',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          selectedImages.asMap().entries.map((e) {
                            int idx = e.key;
                            XFile img = e.value;
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(img.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(
                                          () => selectedImages.removeAt(idx),
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: errorRed,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    vm.isLoading
                        ? null
                        : () async {
                          if (widget.existingPlant == null) {
                            // ➕ Tambah baru
                            bool allSuccess = true;
                            // for (var plantIds in selectedPlantIds) {
                            final success = await vm.submitPlantByAdmin(
                              userId: selectedUserId!,
                              plantIds: selectedPlantIds,
                              address: alamatController.text,
                              latitude: double.tryParse(latController.text),
                              longitude: double.tryParse(lngController.text),
                              notes:
                                  catatanController.text.isNotEmpty
                                      ? catatanController.text
                                      : null,
                              images: selectedImages,
                            );
                            if (!success) allSuccess = false;
                            // }
                            if (allSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Berhasil menambahkan tanaman"),
                                ),
                              );
                              Navigator.pop(context, true);
                            }
                          } else {
                            // ✏️ Update existing
                            final success = await vm.updatePlant(
                              id: widget.existingPlant!["id"],
                              address: alamatController.text,
                              latitude: double.tryParse(latController.text),
                              longitude: double.tryParse(lngController.text),
                              notes:
                                  catatanController.text.isNotEmpty
                                      ? catatanController.text
                                      : null,
                              images: selectedImages,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Tanaman berhasil diupdate"),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: vm.isLoading ? textSecondary : primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: primaryGreen.withOpacity(0.3),
                ),
                child:
                    vm.isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Menyimpan...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : const Text(
                          "Simpan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Optional: Fungsi compress image < 500KB
  Future<XFile?> compressImageUnder500KB(XFile file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        "compressed_${p.basename(file.path)}",
      );

      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 600,
      );

      if (result != null && await result.length() < 500 * 1024) {
        return XFile(result.path);
      }

      return XFile(result?.path ?? file.path);
    } catch (e) {
      _showErrorSnackBar("Gagal mengompres gambar: $e");
      return null;
    }
  }
}
