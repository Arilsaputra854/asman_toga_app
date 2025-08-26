import 'package:flutter/material.dart';

class PlantsPage extends StatelessWidget {
  const PlantsPage({super.key});

  final List<Map<String, String>> plants = const [
    {
      "name": "Aloe Vera",
      "description":
          "Aloe vera dikenal karena manfaat penyembuhannya dan sering digunakan untuk perawatan kulit.",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/c/cb/Aloe_vera_flower.JPG",
    },
    {
      "name": "Lidah Mertua",
      "description":
          "Tanaman hias populer yang tahan lama, bisa menyerap polusi udara di dalam rumah.",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/f/fb/Sansevieria_trifasciata.jpg",
    },
    {
      "name": "Monstera",
      "description":
          "Tanaman hias dengan daun berlubang khas, sering jadi dekorasi rumah modern.",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/9/9d/Monstera_deliciosa_leaves.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plants"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.green, // ✅ background hijau
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  plant["image"]!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // ✅ fallback kalau gambar gagal
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.white24,
                      child: const Icon(
                        Icons.eco, // ikon tanaman
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              title: Text(
                plant["name"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white, // ✅ teks putih
                ),
              ),
              subtitle: Text(
                plant["description"]!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70, // ✅ subtitle putih agak transparan
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetailPage(plant: plant),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PlantDetailPage extends StatelessWidget {
  final Map<String, String> plant;

  const PlantDetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plant["name"]!)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(plant["image"]!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              plant["name"]!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(plant["description"]!, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
