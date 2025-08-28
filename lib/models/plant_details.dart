class PlantDetails {
  final int id;
  final String plantName;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlantDetails({
    required this.id,
    required this.plantName,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantDetails.fromJson(Map<String, dynamic> json) {
    return PlantDetails(
      id: json['id'],
      plantName: json['plant_name'],
      slug: json['slug'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "plant_name": plantName,
      "slug": slug,
      "CreatedAt": createdAt.toIso8601String(),
      "UpdatedAt": updatedAt.toIso8601String(),
    };
  }
}
