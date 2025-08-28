import 'package:asman_toga/service/api_service.dart';
import 'package:asman_toga/models/plant_details.dart';
import 'package:flutter/material.dart';

class PlantDetailPage extends StatefulWidget {
  final String slug;
  const PlantDetailPage({super.key, required this.slug});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  PlantDetails? _plantDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final detail = await ApiService.getPlantDetail(widget.slug);
    setState(() {
      _plantDetail = detail;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.slug)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plantDetail == null
              ? const Center(child: Text("Detail tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // sementara API belum ada field "image", skip dulu
                      const SizedBox(height: 16),
                      Text(
                        _plantDetail!.plantName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Slug: ${_plantDetail!.slug}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Dibuat: ${_plantDetail!.createdAt}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
    );
  }
}
