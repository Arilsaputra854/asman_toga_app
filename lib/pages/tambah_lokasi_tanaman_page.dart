import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TambahLokasiTanamanPage extends StatefulWidget {
  const TambahLokasiTanamanPage({super.key});

  @override
  State<TambahLokasiTanamanPage> createState() =>
      _TambahLokasiTanamanPageState();
}

class _TambahLokasiTanamanPageState extends State<TambahLokasiTanamanPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  LatLng selectedLocation = LatLng(-8.544444, 115.423333); // Desa Gunaksa

  // 👉 polygon batas Desa Gunaksa (contoh dummy, nanti ganti dengan hasil geojson asli)
  final List<LatLng> desaGunaksaPolygon = [
    LatLng(-8.5400, 115.4200),
    LatLng(-8.5400, 115.4300),
    LatLng(-8.5500, 115.4300),
    LatLng(-8.5500, 115.4200),
    LatLng(-8.5400, 115.4200),
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambahkan Lokasi Tanaman",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Lengkap
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                hintText: "Nama Lengkap",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Alamat
            TextFormField(
              controller: alamatController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_outlined),
                hintText: "Alamat",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Latitude Longitude
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: latController,
                    decoration: InputDecoration(
                      hintText: "Latitude",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: lngController,
                    decoration: InputDecoration(
                      hintText: "Longitude",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Map
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: FlutterMap(                  
                  options: MapOptions(                    
                    center: selectedLocation,
                    zoom: 13,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLocation = point;
                        latController.text = point.latitude.toStringAsFixed(6);
                        lngController.text = point.longitude.toStringAsFixed(6);
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLocation,
                          width: 40,
                          height: 40,
                          builder:
                              (context) => const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 40,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Catatan opsional
            TextFormField(
              controller: catatanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Catatan Tambahan (opsional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  debugPrint("Nama: ${namaController.text}");
                  debugPrint("Alamat: ${alamatController.text}");
                  debugPrint(
                    "Lat: ${latController.text}, Lng: ${lngController.text}",
                  );
                  debugPrint("Catatan: ${catatanController.text}");
                },
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
