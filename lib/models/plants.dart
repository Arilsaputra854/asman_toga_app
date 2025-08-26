class Plant {
  final String id;
  final String plantName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plant({
    required this.id,
    required this.plantName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      plantName: json['plant_name'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "plant_name": plantName,
        "notes": notes,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
