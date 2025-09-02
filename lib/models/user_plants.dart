class UserPlant {
  final String id;
  final String userId;
  final int plantId; // kalau plant_id di API number, boleh tetap int
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Map<String, dynamic>? plant;
  final Map<String, dynamic>? user;
  final List<dynamic>? images;

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
    this.plant,
    this.user,
    this.images,
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    final location = json['location'];

    return UserPlant(
      id: json['id'], // String UUID
      userId: location?['user_id'], // String UUID
      plantId: json['plant_id'] is int
          ? json['plant_id']
          : int.parse(json['plant_id'].toString()),
      address: location?['address'],
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      notes: location?['notes'],
      status: json['status'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
      plant: json['plant'],
      user: location?['user'],
      images: json['images'],
    );
  }
}
