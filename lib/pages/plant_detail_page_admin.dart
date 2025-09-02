import 'package:asman_toga/pages/tambah_lokasi_tanaman_page.dart';
import 'package:flutter/material.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlantDetailPage extends StatelessWidget {
  final Map<String, dynamic> plant;
  final VoidCallback onUpdated;

  const PlantDetailPage({
    super.key,
    required this.plant,
    required this.onUpdated,
  });

  Future<void> _approvePlant(BuildContext context, String id) async {
    final result = await ApiService.approveUserPlant(id);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Tanaman berhasil di-approve")),
      );
      onUpdated();
      Navigator.pop(context);
    }
  }

  Future<void> _declinePlant(BuildContext context, String id) async {
    final result = await ApiService.declineUserPlant(id);
    if (result != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Tanaman ditolak")));
      onUpdated();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = plant["location"]["user"];
    final images = plant["images"] as List<dynamic>;
    final firstImage = images.isNotEmpty ? images.first["image_url"] : null;

    final lat = plant["location"]["latitude"];
    final lng = plant["location"]["longitude"];
    final LatLng? plantLatLng =
        (lat != null && lng != null) ? LatLng(lat, lng) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Tanaman"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (firstImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                ApiService.baseUrl + firstImage,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            plant["plant"]["plant_name"],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Pemilik: ${user["name"]}"),
          Text("Alamat: ${plant["location"]["address"] ?? "-"}"),
          Text("Status: ${plant["status"]}"),

          const SizedBox(height: 24),

          // ✅ Map Preview
          if (plantLatLng != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(center: plantLatLng, zoom: 14),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
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
                          point: plantLatLng,
                          width: 40,
                          height: 40,
                          builder:
                              (_) => Tooltip(
                                message:
                                    "${plant["plant"]["plant_name"]}\n${plant["location"]["address"] ?? "-"}\nStatus: ${plant["status"]}",
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Approve / Decline buttons
          // Approve button saja, tanpa update
// Approve / Decline buttons
if (plant["status"] != "approved")
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.check),
        label: const Text("Approve"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () => _approvePlant(context, plant["id"]),
      ),
      ElevatedButton.icon(
        icon: const Icon(Icons.close),
        label: const Text("Decline"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () => _declinePlant(context, plant["id"]),
      ),
    ],
  ),


        ],
      ),
    );
  }
}
