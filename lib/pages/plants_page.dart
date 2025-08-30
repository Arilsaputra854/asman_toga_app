import 'package:asman_toga/models/plant_details.dart';
import 'package:asman_toga/models/plants.dart';
import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  late Future<List<Plant>> _plantsFuture;
  final Map<String, bool> _expandedStatus = {}; // untuk track open/close tiap plant
  final Map<String, PlantDetails?> _plantDetailsCache = {}; // cache detail

  @override
  void initState() {
    super.initState();
    _plantsFuture = _fetchPlants();
  }

  Future<List<Plant>> _fetchPlants() async {
    return await ApiService.getPlants();
  }

  Future<PlantDetails?> _fetchPlantDetail(String slug) async {
    // Cek cache dulu
    if (_plantDetailsCache.containsKey(slug)) {
      return _plantDetailsCache[slug];
    }

    final detail = await ApiService.getPlantDetail(slug);
    _plantDetailsCache[slug] = detail;
    return detail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final isExpanded = _expandedStatus[plant.slug] ?? false;

              return Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  elevation: 3,
  margin: const EdgeInsets.symmetric(vertical: 6),
  child: Theme(
    data: Theme.of(context).copyWith(
      dividerColor: Colors.transparent, // hilangkan garis default ExpansionTile
    ),
    child: ExpansionTile(
      key: Key(plant.slug),
      leading: const Icon(Icons.eco, color: Colors.green, size: 32),
      title: Text(
        plant.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
      ),
      initiallyExpanded: isExpanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onExpansionChanged: (expanded) {
        setState(() {
          _expandedStatus[plant.slug] = expanded;
        });
      },
      children: [
        FutureBuilder<PlantDetails?>(
          future: _fetchPlantDetail(plant.slug),
          builder: (context, detailSnapshot) {
            if (detailSnapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (detailSnapshot.hasError || detailSnapshot.data == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Detail tidak ditemukan"),
              );
            }

            final detail = detailSnapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.plantName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Slug: ${detail.slug}"),
                  const SizedBox(height: 4),
                  Text(
                    "Dibuat: ${detail.createdAt}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  ),
);

            },
          );
        },
      ),
    );
  }
}
