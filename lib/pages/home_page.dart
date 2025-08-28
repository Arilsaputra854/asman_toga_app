import 'package:asman_toga/pages/about_page.dart';
import 'package:asman_toga/pages/plants_page.dart';
import 'package:asman_toga/service/api_service.dart';
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
  bool isLoadingUserPlants = false; 
  List<Map<String, dynamic>> userPlants = []; 
  int _currentIndex = 0;
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    _viewModel.fetchProfile().then((_) {
      setState(() {});
    });
    _viewModel.fetchPlants().then((_){
      setState(() {
        
      });
    });
    fetchUserPlants(); 
    super.initState();
  }

  Future<void> fetchUserPlants() async {
  setState(() {
    isLoadingUserPlants = true;
  });

  final result = await ApiService.getUserPlants();

  setState(() {
    userPlants = List<Map<String, dynamic>>.from(result);
    isLoadingUserPlants = false;
  });
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
          // List tanaman pakai Wrap (Chip style)
_viewModel.isLoadingPlants
    ? const Center(child: CircularProgressIndicator())
    : _viewModel.plants.isEmpty
        ? const Text("Tidak ada tanaman")
        : Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _viewModel.plants.map((plant) {
              return Chip(
                label: Text(plant.name),
                backgroundColor: Colors.green,
                labelStyle: const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Map Preview (non-interaktif)
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: SizedBox(
    height: 200,
    child: FlutterMap(
      options: MapOptions(
        center: LatLng(-8.544444, 115.423333),
        zoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),

        // PolygonLayer yang sudah ada
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

        // ⬅️ Tambahkan MarkerLayer untuk userPlants
        if (!isLoadingUserPlants)
          MarkerLayer(
            markers: userPlants.map((plant) {
              final lat = plant['latitude'];
              final lng = plant['longitude'];
              if (lat != null && lng != null) {
                return Marker(
                  point: LatLng(lat, lng),
                  width: 35,
                  height: 35,
                  builder: (_) => Tooltip(
                    message:
                        "${plant['plant']['plant_name']}\n${plant['address']}\nStatus: ${plant['status']}",
                    child: const Icon(
                      Icons.local_florist,
                      color: Colors.green,
                      size: 35,
                    ),
                  ),
                );
              }
              return Marker(
                point: LatLng(0, 0),
                width: 0,
                height: 0,
                builder: (_) => const SizedBox(),
              );
            }).toList(),
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
