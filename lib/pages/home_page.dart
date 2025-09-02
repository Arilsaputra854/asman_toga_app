import 'package:asman_toga/models/user_plants.dart';
import 'package:asman_toga/pages/about_page.dart';
import 'package:asman_toga/pages/plants_page.dart';
import 'package:asman_toga/pages/user_plant_detail_page.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:asman_toga/viewmodel/home_viewmodel.dart';
import 'package:asman_toga/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:asman_toga/pages/tambah_lokasi_tanaman_page.dart';
import 'package:asman_toga/pages/profile_page.dart';

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
    super.initState();
    _viewModel.fetchProfile().then((_) => setState(() {}));
    _viewModel.fetchPlants().then((_) => setState(() {}));
    fetchUserPlants();
  }

  Future<void> fetchUserPlants() async {
    setState(() => isLoadingUserPlants = true);
    final result = await ApiService.getUserPlants();
    setState(() {
      userPlants = List<Map<String, dynamic>>.from(result);
      isLoadingUserPlants = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Halaman konten untuk setiap tab
    final pages = [
      HomeContent(
        viewModel: _viewModel,
        userPlants: userPlants,
        isLoadingUserPlants: isLoadingUserPlants,
      ),
      const AboutPage(),
      const PlantsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header tetap di atas semua tab
            CustomHeader(
              title:
                  _viewModel.isLoading
                      ? "Loading..."
                      : "Hi, ${_viewModel.user?.name ?? "User"}",
              subtitle: "Lorem ipsum dolor sit",
            ),

            // Konten halaman scrollable
            Expanded(child: pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Plants"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/// Konten halaman Home dengan filter map pakai chip
class HomeContent extends StatefulWidget {
  final HomeViewModel viewModel;
  final List<Map<String, dynamic>> userPlants;
  final bool isLoadingUserPlants;

  const HomeContent({
    super.key,
    required this.viewModel,
    required this.userPlants,
    required this.isLoadingUserPlants,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int? selectedPlantId; // null = semua tanaman

  @override
  Widget build(BuildContext context) {
    // Filter userPlants sesuai chip
    final filteredPlants =
        widget.userPlants.where((plant) {
          if (plant['status'] != 'approved') return false;
          if (selectedPlantId != null &&
              plant['plant']?['id'] != selectedPlantId)
            return false;
          return true;
        }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Chip Filter Maks 2 Baris
          // Maks 2 baris chip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text("Semua"),
                          selected: selectedPlantId == null,
                          onSelected: (_) {
                            setState(() => selectedPlantId = null);
                          },
                        ),
                        const SizedBox(width: 8),
                        ...widget.viewModel.plants
                            .asMap()
                            .entries
                            .where((e) => e.key.isEven)
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  backgroundColor:
                                      Colors
                                          .green
                                          .shade400, // warna chip normal
                                  selectedColor: Colors.green.shade700,
                                  label: Text(
    e.value.name,
    style: TextStyle(
      color: selectedPlantId == e.value.id ? Colors.white : Colors.white70,
      fontWeight: FontWeight.bold,
    ),
  ),

                                  selected: selectedPlantId == e.value.id,
                                  onSelected: (val) {
                                    setState(() {
                                      selectedPlantId = val ? e.value.id : null;
                                    });
                                  },
                                ),
                              ),
                            ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children:
                          widget.viewModel.plants
                              .asMap()
                              .entries
                              .where((e) => e.key.isOdd)
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    backgroundColor:
                                        Colors
                                            .green
                                            .shade400, // warna chip normal
                                    selectedColor: Colors.green.shade700,
                                    label: Text(
    e.value.name,
    style: TextStyle(
      color: selectedPlantId == e.value.id ? Colors.white : Colors.white70,
      fontWeight: FontWeight.bold,
    ),
  ),
                                    selected: selectedPlantId == e.value.id,
                                    onSelected: (val) {
                                      setState(() {
                                        selectedPlantId =
                                            val ? e.value.id : null;
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // // List tanaman 2 baris (optional, bisa tetap dipakai)
          // SizedBox(
          //   height: 120,
          //   child: widget.viewModel.isLoadingPlants
          //       ? const Center(child: CircularProgressIndicator())
          //       : widget.viewModel.plants.isEmpty
          //           ? const Text("Tidak ada tanaman")
          //           : ListView.builder(
          //               scrollDirection: Axis.horizontal,
          //               itemCount: (widget.viewModel.plants.length / 2).ceil(),
          //               itemBuilder: (context, index) {
          //                 final firstIndex = index * 2;
          //                 final secondIndex = firstIndex + 1;

          //                 final firstName = firstIndex < widget.viewModel.plants.length
          //                     ? widget.viewModel.plants[firstIndex].name
          //                     : "";
          //                 final secondName = secondIndex < widget.viewModel.plants.length
          //                     ? widget.viewModel.plants[secondIndex].name
          //                     : "";

          //                 final longestName = (firstName.length > secondName.length)
          //                     ? firstName
          //                     : secondName;

          //                 return Container(
          //                   margin: const EdgeInsets.only(right: 12),
          //                   child: Column(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       if (firstIndex < widget.viewModel.plants.length)
          //                         ConstrainedBox(
          //                           constraints: BoxConstraints(
          //                               minWidth: longestName.length * 10.0),
          //                           child: Chip(
          //                             label: Text(
          //                               firstName,
          //                               style: const TextStyle(
          //                                   fontSize: 14, color: Colors.white),
          //                             ),
          //                             backgroundColor: Colors.green,
          //                             padding: const EdgeInsets.symmetric(
          //                                 horizontal: 12, vertical: 4),
          //                           ),
          //                         ),
          //                       const SizedBox(height: 10),
          //                       if (secondIndex < widget.viewModel.plants.length)
          //                         ConstrainedBox(
          //                           constraints: BoxConstraints(
          //                               minWidth: longestName.length * 10.0),
          //                           child: Chip(
          //                             label: Text(
          //                               secondName,
          //                               style: const TextStyle(
          //                                   fontSize: 14, color: Colors.white),
          //                             ),
          //                             backgroundColor: Colors.green,
          //                             padding: const EdgeInsets.symmetric(
          //                                 horizontal: 12, vertical: 4),
          //                           ),
          //                         ),
          //                     ],
          //                   ),
          //                 );
          //               },
          //             ),
          // ),

          // const SizedBox(height: 20),

          // Map Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  center:
                      filteredPlants.isNotEmpty
                          ? LatLng(
                            filteredPlants[0]['location']?['latitude'] ?? 0,
                            filteredPlants[0]['location']?['longitude'] ?? 0,
                          )
                          : LatLng(-8.544444, 115.423333),
                  zoom: 12.5,
                ),
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
                  if (!widget.isLoadingUserPlants)
                    MarkerLayer(
                      markers:
                          filteredPlants.map((plant) {
                            final location = plant['location'];
                            final lat = location?['latitude'];
                            final lng = location?['longitude'];
                            final images = plant['images'] as List<dynamic>?;

                            final imageUrl =
                                (images != null && images.isNotEmpty)
                                    ? ApiService.baseUrl +
                                        images[0]['image_url']
                                    : null;

                            if (lat != null && lng != null) {
                              return Marker(
                                point: LatLng(lat, lng),
                                width: 50,
                                height: 50,
                                builder:
                                    (ctx) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => UserPlantDetailPage(
                                                  userPlant: UserPlant.fromJson(
                                                    plant,
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.green.shade200,
                                        backgroundImage:
                                            imageUrl != null
                                                ? NetworkImage(imageUrl)
                                                : null,
                                        child:
                                            imageUrl == null
                                                ? const Icon(
                                                  Icons.local_florist,
                                                  color: Colors.white,
                                                  size: 24,
                                                )
                                                : null,
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
