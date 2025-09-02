import 'package:asman_toga/models/user_plants.dart';
import 'package:asman_toga/pages/tambah_lokasi_tanaman_page.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserPlantDetailPage extends StatelessWidget {
  final UserPlant userPlant;

  const UserPlantDetailPage({super.key, required this.userPlant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Tanaman"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card utama untuk gambar dan info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Tanaman
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: userPlant.images != null && userPlant.images!.isNotEmpty
                            ? Image.network(
                                ApiService.baseUrl + userPlant.images![0]['image_url'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.green.shade200,
                                child: const Icon(Icons.local_florist,
                                    color: Colors.white, size: 48),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Tanaman
                    Text(
                      "Nama: ${userPlant.plant?['plant_name'] ?? 'Tanaman'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Alamat: ${userPlant.address ?? '-'}",
                      style: const TextStyle(fontSize: 14),
                    ),

                    Text(
                      "Nama Pemilik: ${userPlant.user?["name"] ?? '-'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Catatan: ${userPlant.notes ?? '-'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Latitude: ${userPlant.latitude ?? '-'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Longitude: ${userPlant.longitude ?? '-'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Map Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 250,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(userPlant.latitude ?? 0, userPlant.longitude ?? 0),
                      zoom: 15,
                    ),
                    children: [
                      TileLayer(
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                  ),
                  // PolygonLayer
                  PolygonLayer(
                    polygons: [
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
                            point: LatLng(userPlant.latitude ?? 0, userPlant.longitude ?? 0),
                            width: 50,
                            height: 50,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tombol tambahan (misal kembali atau edit)
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kembali",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
