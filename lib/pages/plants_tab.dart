import 'package:flutter/material.dart';
import '../service/api_service.dart';
import 'package:asman_toga/pages/create_user_plants_admin.dart';

class PlantsTab extends StatefulWidget {
  const PlantsTab({super.key});

  @override
  State<PlantsTab> createState() => _PlantsTabState();
}

class _PlantsTabState extends State<PlantsTab> {
  bool isLoading = true;
  List<Map<String, dynamic>> plants = [];
  List<Map<String, dynamic>> filteredPlants = [];

  // Search
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Color palette
  static const Color primaryGreen = Color(0xFF57A32E);
  static const Color lightGreen = Color(0xFF7BC142);
  static const Color backgroundColor = Color(0xFFF8FAF6);
  static const Color cardColor = Colors.white;
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    fetchUserPlants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      _filterPlants();
    });
  }

  void _filterPlants() {
    if (searchQuery.isEmpty) {
      filteredPlants = plants;
    } else {
      filteredPlants =
          plants.where((plant) {
            final plantName =
                plant["plant"]?["plant_name"]?.toString().toLowerCase() ?? "";
            final userName =
                plant["location"]?["user"]?["name"]?.toString().toLowerCase() ??
                "";
            return plantName.contains(searchQuery) ||
                userName.contains(searchQuery);
          }).toList();
    }
  }

  Future<void> fetchUserPlants({bool refresh = false}) async {
    setState(() => isLoading = true);
    try {
      final result = await ApiService.getUserPlants();
      plants = List<Map<String, dynamic>>.from(result);
      _filterPlants();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data plants: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 16, color: textPrimary),
        decoration: InputDecoration(
          hintText: "Cari tanaman atau user...",
          hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.search_rounded, color: primaryGreen, size: 20),
          ),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: textSecondary),
                    onPressed: () => _searchController.clear(),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, lightGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_florist_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Plants",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${filteredPlants.length}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (searchQuery.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Filtered",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    final plantName = plant["plant"]?["plant_name"] ?? "-";
    final status = plant["status"] ?? "-";
    final userName = plant["location"]?["user"]?["name"] ?? "-";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: primaryGreen,
          child: Text(
            plantName.toString()[0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          plantName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: textSecondary),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "Status: $status",
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: textSecondary),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "User: $userName",
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // trailing: PopupMenuButton<String>(
        //   icon: Icon(Icons.more_vert_rounded, color: primaryGreen),
        //   onSelected: (value) {
        //     if (value == 'edit') {
        //       // TODO: edit plant
        //     } else if (value == 'delete') {
        //       // TODO: delete plant
        //     }
        //   },
        //   itemBuilder:
        //       (context) => [
        //         PopupMenuItem(
        //           value: 'edit',
        //           child: Row(
        //             children: [
        //               Icon(Icons.edit_outlined, size: 18, color: primaryGreen),
        //               SizedBox(width: 8),
        //               Text('Edit Plant'),
        //             ],
        //           ),
        //         ),
        //         PopupMenuItem(
        //           value: 'delete',
        //           child: Row(
        //             children: [
        //               Icon(Icons.delete_outline, size: 18, color: errorRed),
        //               SizedBox(width: 8),
        //               Text('Hapus Plant'),
        //             ],
        //           ),
        //         ),
        //       ],
        // ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        title: Text(
          "Manage Plants",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.refresh_rounded, color: primaryGreen, size: 20),
            ),
            onPressed: () => fetchUserPlants(refresh: true),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryGreen))
              : filteredPlants.isEmpty && searchQuery.isNotEmpty
              ? Center(child: Text("Tidak ada hasil"))
              : filteredPlants.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_florist_rounded,
                      size: 80,
                      color: textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Belum ada tanaman users",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tambahkan tanaman user pertama dengan\nmenekan tombol + di bawah",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: fetchUserPlants,
                color: primaryGreen,
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildStatsCard(),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredPlants.length,
                        itemBuilder:
                            (context, index) =>
                                _buildPlantCard(filteredPlants[index]),
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateUserPlantsAdmin()),
          );
          if (refreshed == true) fetchUserPlants();
        },
        backgroundColor: primaryGreen,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Tambah Plant",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
