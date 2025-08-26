import 'package:asman_toga/pages/about_page.dart';
import 'package:asman_toga/pages/plants_page.dart';
import 'package:asman_toga/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:asman_toga/pages/tambah_lokasi_tanaman_page.dart';
import 'package:asman_toga/pages/profile_page.dart'; // Import ProfilePage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    _viewModel.fetchProfile().then((_) {
      setState(() {}); // update UI setelah fetch selesai
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(context),
      AboutPage(),
      PlantsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Plants"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _viewModel.isLoading
                        ? "Loading..."
                        : (_viewModel.user != null
                            ? "Hi, ${_viewModel.user!.name}"
                            : "Hi, User"),
                  ),
                  const Text(
                    "Lorem ipsum dolor sit",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Card Info
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Image.asset("assets/logo.png", height: 50),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "ASMAN TOGA\nLorem ipsum dolor sit amet consectetur adipisicing elit. Tempora, nesciunt?",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const TambahLokasiTanamanPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Tambahkan Tanaman",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List tanaman pakai Wrap (Chip style)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(
                label: Text("Jahe Merah"),
                backgroundColor: Colors.green, // ✅ hijau
                labelStyle: TextStyle(color: Colors.white), // ✅ teks putih
              ),
              Chip(
                label: Text("Sereh"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
              Chip(
                label: Text("Kunyit"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
              Chip(
                label: Text("Kelor"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
              Chip(
                label: Text("Sirih"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
              Chip(
                label: Text("Kumis Kucing"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
              Chip(
                label: Text("Daun Telang"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Map Preview (non-interaktif)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(
                    -8.544444,
                    115.423333,
                  ), // titik tengah Desa Gunaksa
                  zoom: 15,
                  interactiveFlags:
                      InteractiveFlag.none, // kalau mau non-aktif geser/zoom
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                  ),

                  // Tambahkan PolygonLayer
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: [
                          LatLng(-8.5450, 115.4210),
                          LatLng(-8.5460, 115.4260),
                          LatLng(-8.5430, 115.4285),
                          LatLng(-8.5415, 115.4235),
                        ],
                        color: Colors.grey.withValues(alpha: 0), // warna isi
                        borderStrokeWidth: 2,
                        borderColor: Colors.green, // warna garis
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
