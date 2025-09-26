class Realtor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photo;
  final String creci;
  final String? bio;
  final DateTime createdAt;
  final bool isActive;
  final int totalProperties;
  final int soldProperties;

  Realtor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
    required this.creci,
    this.bio,
    required this.createdAt,
    this.isActive = true,
    this.totalProperties = 0,
    this.soldProperties = 0,
  });

  Realtor copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photo,
    String? creci,
    String? bio,
    DateTime? createdAt,
    bool? isActive,
    int? totalProperties,
    int? soldProperties,
  }) {
    return Realtor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      creci: creci ?? this.creci,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      totalProperties: totalProperties ?? this.totalProperties,
      soldProperties: soldProperties ?? this.soldProperties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'creci': creci,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'totalProperties': totalProperties,
      'soldProperties': soldProperties,
    };
  }

  factory Realtor.fromJson(Map<String, dynamic> json) {
    return Realtor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photo: json['photo'],
      creci: json['creci'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      totalProperties: json['totalProperties'] ?? 0,
      soldProperties: json['soldProperties'] ?? 0,
    );
  }
}
