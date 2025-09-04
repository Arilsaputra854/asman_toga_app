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

  // Color palette - same as DashboardTab
  static const Color primaryGreen = Color(0xFF57A32E);
  static const Color lightGreen = Color(0xFF7BC142);
  static const Color backgroundColor = Color(0xFFF8FAF6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _viewModel.fetchProfile().then((_) => setState(() {}));
    _viewModel.fetchPlants().then((_) => setState(() {}));
    fetchUserPlants();
  }

  Future<void> fetchUserPlants() async {
    setState(() => isLoadingUserPlants = true);
    try {
      final result = await ApiService.getUserPlants();
      setState(() {
        userPlants = List<Map<String, dynamic>>.from(result);
        isLoadingUserPlants = false;
      });
    } catch (e) {
      setState(() => isLoadingUserPlants = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Halaman konten untuk setiap tab
    final pages = [
      HomeContent(
        viewModel: _viewModel,
        userPlants: userPlants,
        isLoadingUserPlants: isLoadingUserPlants,
        onRefresh: fetchUserPlants,
      ),
      const AboutPage(),
      const PlantsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGreen, lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _viewModel.isLoading
                              ? "Loading..."
                              : "Hi, ${_viewModel.user?.name ?? "User"}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Selamat datang di ASMAN TOGA",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Konten halaman scrollable
            Expanded(child: pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: primaryGreen,
          unselectedItemColor: textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: "About",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_rounded),
              label: "Plants",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Home Content with improved design
class HomeContent extends StatefulWidget {
  final HomeViewModel viewModel;
  final List<Map<String, dynamic>> userPlants;
  final bool isLoadingUserPlants;
  final VoidCallback onRefresh;

  const HomeContent({
    super.key,
    required this.viewModel,
    required this.userPlants,
    required this.isLoadingUserPlants,
    required this.onRefresh,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int? selectedPlantId; // null = semua tanaman

  // Color palette
  static const Color primaryGreen = Color(0xFF57A32E);
  static const Color lightGreen = Color(0xFF7BC142);
  static const Color backgroundColor = Color(0xFFF8FAF6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

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

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      color: primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryGreen, lightGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_florist_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "ASMAN TOGA",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Kelola dan pantau tanaman TOGA Anda dengan mudah",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: primaryGreen.withOpacity(0.3),
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
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          "Tambahkan Tanaman",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.eco_rounded,
                            color: primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${filteredPlants.length}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          "Tanaman",
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: lightGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            color: lightGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${widget.viewModel.plants.length}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          "Jenis",
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Filter Section
            Text(
              "Filter Tanaman",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Modern Chip Filter
            SizedBox(
              height: 120,
              child: Column(
                children: [
                  // First row with "Semua" chip
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip("Semua", selectedPlantId == null, () {
                          setState(() => selectedPlantId = null);
                        }),
                        const SizedBox(width: 8),
                        ...widget.viewModel.plants
                            .asMap()
                            .entries
                            .where((e) => e.key.isEven)
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildFilterChip(
                                  e.value.name,
                                  selectedPlantId == e.value.id,
                                  () {
                                    setState(() {
                                      selectedPlantId =
                                          selectedPlantId == e.value.id
                                              ? null
                                              : e.value.id;
                                    });
                                  },
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Second row
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          widget.viewModel.plants
                              .asMap()
                              .entries
                              .where((e) => e.key.isOdd)
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildFilterChip(
                                    e.value.name,
                                    selectedPlantId == e.value.id,
                                    () {
                                      setState(() {
                                        selectedPlantId =
                                            selectedPlantId == e.value.id
                                                ? null
                                                : e.value.id;
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Map Section
            Text(
              "Peta Lokasi Tanaman",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 250,
                  child:
                      widget.isLoadingUserPlants
                          ? Container(
                            color: cardColor,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Memuat peta...",
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : FlutterMap(
                            options: MapOptions(
                              center:
                                  filteredPlants.isNotEmpty
                                      ? LatLng(
                                        filteredPlants[0]['location']?['latitude'] ??
                                            0,
                                        filteredPlants[0]['location']?['longitude'] ??
                                            0,
                                      )
                                      : LatLng(-8.544444, 115.423333),
                              zoom: 12.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                                subdomains: const ['a', 'b', 'c'],
                                userAgentPackageName: 'com.example.app',
                              ),
                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: desaGunaksaPolygon,
                                    color: primaryGreen.withOpacity(0.1),
                                    borderStrokeWidth: 2,
                                    borderColor: primaryGreen,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers:
                                    filteredPlants.map((plant) {
                                      final location = plant['location'];
                                      final lat = location?['latitude'];
                                      final lng = location?['longitude'];
                                      final images =
                                          plant['images'] as List<dynamic>?;

                                      final imageUrl =
                                          (images != null && images.isNotEmpty)
                                              ? ApiService.baseUrl +
                                                  images[0]['image_url']
                                              : null;

                                      if (lat != null && lng != null) {
                                        return Marker(
                                          point: LatLng(lat, lng),
                                          width: 60,
                                          height: 60,
                                          builder:
                                              (ctx) => GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            _,
                                                          ) => UserPlantDetailPage(
                                                            userPlant:
                                                                UserPlant.fromJson(
                                                                  plant,
                                                                ),
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: cardColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: primaryGreen,
                                                      width: 3,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: primaryGreen
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 27,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage:
                                                        imageUrl != null
                                                            ? NetworkImage(
                                                              imageUrl,
                                                            )
                                                            : null,
                                                    child:
                                                        imageUrl == null
                                                            ? Icon(
                                                              Icons
                                                                  .local_florist_rounded,
                                                              color:
                                                                  primaryGreen,
                                                              size: 24,
                                                            )
                                                            : null,
                                                  ),
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
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [primaryGreen, lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? Colors.transparent : primaryGreen.withOpacity(0.3),
            width: 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
