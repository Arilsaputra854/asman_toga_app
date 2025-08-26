class UserPlant {
  final String id;
  final String userId;
  final String plantId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final String status; // pending, approved, rejected
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPlant({
    required this.id,
    required this.userId,
    required this.plantId,
    this.address,
    this.latitude,
    this.longitude,
    this.notes,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    return UserPlant(
      id: json['id'],
      userId: json['user_id'],
      plantId: json['plant_id'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: json['notes'],
      status: json['status'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "plant_id": plantId,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "notes": notes,
        "status": status,
        "approved_by": approvedBy,
        "approved_at": approvedAt?.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
