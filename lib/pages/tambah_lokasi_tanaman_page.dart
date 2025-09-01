import 'dart:io';

import 'package:asman_toga/viewmodel/tambah_lokasi_tanaman_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:provider/provider.dart';

class TambahLokasiTanamanPage extends StatefulWidget {
  const TambahLokasiTanamanPage({super.key});

  @override
  State<TambahLokasiTanamanPage> createState() =>
      _TambahLokasiTanamanPageState();
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

class _TambahLokasiTanamanPageState extends State<TambahLokasiTanamanPage> {
  List<XFile> selectedImages = [];
  List<int> selectedPlantIds = [];
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  LatLng selectedLocation = LatLng(-8.544444, 115.423333); // Titik awal

  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    latController.text = selectedLocation.latitude.toStringAsFixed(6);
    lngController.text = selectedLocation.longitude.toStringAsFixed(6);

    context.read<TambahLokasiTanamanViewModel>().getAllPlants();
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images != null) {
      List<XFile> validImages = [];
      for (var img in images) {
        final bytes = await img.length();
        if (bytes <= 500 * 1024) {
          validImages.add(img);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${img.name} lebih dari 500KB, dilewati")),
          );
        }
      }
      setState(() {
        selectedImages = validImages;
      });
    }
  }

  Future<void> goToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Aktifkan layanan lokasi")));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Izin lokasi ditolak")));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Izin lokasi ditolak permanen, buka pengaturan"),
        ),
      );
      return;
    }

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi Anda di luar polygon")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TambahLokasiTanamanViewModel>(context);
    return ChangeNotifierProvider(
      create: (_) => TambahLokasiTanamanViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tambahkan Lokasi Tanaman"),
          centerTitle: true,
        ),
body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: alamatController,
                decoration: InputDecoration(
                  labelText: "Alamat",
                  prefixIcon: const Icon(Icons.home),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: latController,
                      decoration: InputDecoration(
                        labelText: "Latitude",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: lngController,
                      decoration: InputDecoration(
                        labelText: "Longitude",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 20),

              SizedBox(
                height: 300,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: selectedLocation,
                    zoom: 16,
                    interactiveFlags: InteractiveFlag.all,
                    onTap: (tapPos, point) {
                      if (isPointInPolygon(point, desaGunaksaPolygon)) {
                        setState(() {
                          selectedLocation = point;
                          latController.text = point.latitude.toStringAsFixed(
                            6,
                          );
                          lngController.text = point.longitude.toStringAsFixed(
                            6,
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lokasi di luar polygon"),
                          ),
                        );
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    PolygonLayer(
                      polygons: [
                        // Polygon besar menutupi seluruh peta
                        Polygon(
                          points: [
                            LatLng(-90, -180), // seluruh dunia
                            LatLng(-90, 180),
                            LatLng(90, 180),
                            LatLng(90, -180),
                          ],
                          holePointsList: [
                            desaGunaksaPolygon,
                          ], // lubang sesuai desa
                          color: Colors.white.withOpacity(0.9), // overlay luar
                        ),

                        // Polygon desa (border/hilight)
                        Polygon(
                          points: desaGunaksaPolygon,
                          color: Colors.green.withOpacity(0.1),
                          borderStrokeWidth: 2,
                          borderColor: Colors.green,
                        ),
                      ],
                    ),

                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLocation,
                          width: 40,
                          height: 40,
                          builder:
                              (_) => const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
      Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          onPressed: goToCurrentLocation,
          icon: const Icon(Icons.my_location),
          label: const Text("Gunakan Lokasi Saya"),
        ),
      ),

      const SizedBox(height: 20),

      // Catatan
      TextFormField(
        controller: catatanController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "Catatan Tambahan (opsional)",
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      const SizedBox(height: 20),

      // Multi select tanaman
      MultiSelectDialogField(
        items: vm.plants
            .map((plant) => MultiSelectItem<int>(plant.id, plant.name))
            .toList(),
        title: const Text("Pilih Tanaman"),
        buttonText: const Text("Tambahkan Tanaman"),
        listType: MultiSelectListType.CHIP,
        searchable: true,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        onConfirm: (values) {
          setState(() => selectedPlantIds = values.cast<int>());
        },
      ),

      const SizedBox(height: 20),

      // Foto
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        onPressed: pickImages,
        icon: const Icon(Icons.add_a_photo,color: Colors.white,),
        label: const Text("Tambah Foto", style: TextStyle(color: Colors.white),),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectedImages
            .map((img) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(img.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ))
            .toList(),
      ),

      const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      vm.isLoading
                          ? null
                          : () async {
                            bool allSuccess = true;

                            for (var plantId in selectedPlantIds) {
                              final success = await vm.submitPlant(
                                plantId: plantId,
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
                            }

                            if (allSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Berhasil menambahkan tanaman"),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Beberapa tanaman gagal ditambahkan",
                                  ),
                                ),
                              );
                            }
                          },

                  child:
                      vm.isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
