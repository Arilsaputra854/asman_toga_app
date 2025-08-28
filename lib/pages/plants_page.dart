import 'package:asman_toga/models/plants.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';
import 'plant_detail_page.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  late Future<List<Plant>> _plantsFuture;

  @override
  void initState() {
    super.initState();
    _plantsFuture = _fetchPlants();
  }

  Future<List<Plant>> _fetchPlants() async {
    return await ApiService.getPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plants"), centerTitle: true),
      body: FutureBuilder<List<Plant>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data tanaman"));
          }

          final plants = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.eco, color: Colors.green, size: 32),
                  title: Text(
                    plant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlantDetailPage(slug: plant.slug),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
