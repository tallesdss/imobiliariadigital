enum PropertyType { house, apartment, commercial, land }

enum PropertyStatus { active, sold, archived, suspended }

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final PropertyType type;
  final PropertyStatus status;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final List<String> photos;
  final List<String> videos;
  final Map<String, dynamic> attributes; // bedrooms, bathrooms, area, etc.
  final String realtorId;
  final String realtorName;
  final String realtorPhone;
  final String adminContact;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFeatured;
  final bool isLaunch;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.status,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.photos,
    required this.videos,
    required this.attributes,
    required this.realtorId,
    required this.realtorName,
    required this.realtorPhone,
    required this.adminContact,
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
    this.isLaunch = false,
  });

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    PropertyType? type,
    PropertyStatus? status,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    List<String>? photos,
    List<String>? videos,
    Map<String, dynamic>? attributes,
    String? realtorId,
    String? realtorName,
    String? realtorPhone,
    String? adminContact,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFeatured,
    bool? isLaunch,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      type: type ?? this.type,
      status: status ?? this.status,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      attributes: attributes ?? this.attributes,
      realtorId: realtorId ?? this.realtorId,
      realtorName: realtorName ?? this.realtorName,
      realtorPhone: realtorPhone ?? this.realtorPhone,
      adminContact: adminContact ?? this.adminContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      isLaunch: isLaunch ?? this.isLaunch,
    );
  }

  String get formattedPrice {
    return 'R\$ ${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get typeDisplayName {
    switch (type) {
      case PropertyType.house:
        return 'Casa';
      case PropertyType.apartment:
        return 'Apartamento';
      case PropertyType.commercial:
        return 'Comercial';
      case PropertyType.land:
        return 'Terreno';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case PropertyStatus.active:
        return 'Ativo';
      case PropertyStatus.sold:
        return 'Vendido';
      case PropertyStatus.archived:
        return 'Arquivado';
      case PropertyStatus.suspended:
        return 'Suspenso';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'type': type.name,
      'status': status.name,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'photos': photos,
      'videos': videos,
      'attributes': attributes,
      'realtorId': realtorId,
      'realtorName': realtorName,
      'realtorPhone': realtorPhone,
      'adminContact': adminContact,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFeatured': isFeatured,
      'isLaunch': isLaunch,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      type: PropertyType.values.firstWhere((e) => e.name == json['type']),
      status: PropertyStatus.values.firstWhere((e) => e.name == json['status']),
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      photos: List<String>.from(json['photos']),
      videos: List<String>.from(json['videos']),
      attributes: Map<String, dynamic>.from(json['attributes']),
      realtorId: json['realtorId'],
      realtorName: json['realtorName'],
      realtorPhone: json['realtorPhone'],
      adminContact: json['adminContact'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isFeatured: json['isFeatured'] ?? false,
      isLaunch: json['isLaunch'] ?? false,
    );
  }
}
