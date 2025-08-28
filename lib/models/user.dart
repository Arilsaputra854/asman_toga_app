class Banjar {
  final int id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;

  Banjar({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Banjar.fromJson(Map<String, dynamic> json) {
    return Banjar(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "CreatedAt": createdAt.toIso8601String(),
        "UpdatedAt": updatedAt.toIso8601String(),
      };
}

class User {
  final String id;
  final int banjarId;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Banjar? banjar;

  User({
    required this.id,
    required this.banjarId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.banjar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      banjarId: json['banjar_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
      banjar: json['banjar'] != null ? Banjar.fromJson(json['banjar']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "banjar_id": banjarId,
        "name": name,
        "email": email,
        "role": role,
        "CreatedAt": createdAt.toIso8601String(),
        "UpdatedAt": updatedAt.toIso8601String(),
        "banjar": banjar?.toJson(),
      };
}
