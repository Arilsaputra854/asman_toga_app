import 'package:asman_toga/pages/plant_detail_page_admin.dart';
import 'package:flutter/material.dart';
import 'package:asman_toga/helper/prefs.dart';
import 'package:asman_toga/service/api_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool isLoading = true;
  List<dynamic> userPlants = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.getUserPlants();
    setState(() {
      userPlants = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group data by user
    final Map<String, List<dynamic>> grouped = {};
    for (var plant in userPlants) {
      final user = plant["location"]["user"];
      final userId = user["id"];
      if (!grouped.containsKey(userId)) {
        grouped[userId] = [];
      }
      grouped[userId]!.add(plant);
    }

    final groupedList = grouped.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await PrefsHelper.clearToken();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                itemCount: groupedList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final plants = groupedList[index];
                  final user = plants[0]["location"]["user"];

                  return ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade200,
                      child: Text(user["name"][0].toUpperCase()),
                    ),
                    title: Text(user["name"]),
                    subtitle: Text("Total tanaman: ${plants.length}"),
                    children:
                        plants
                            .where(
                              (plant) => plant["status"] != "approved",
                            ) // Hanya yang belum approve
                            .map<Widget>((plant) {
                              return ListTile(
                                title: Text(plant["plant"]["plant_name"]),
                                subtitle: Text("Status: ${plant["status"]}"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => PlantDetailPage(
                                            plant: plant,
                                            onUpdated: _loadData,
                                          ),
                                    ),
                                  );
                                },
                              );
                            })
                            .toList(),
                  );
                },
              ),
    );
  }
}
