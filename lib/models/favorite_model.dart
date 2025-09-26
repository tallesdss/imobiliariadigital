class Favorite {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.createdAt,
  });

  Favorite copyWith({
    String? id,
    String? userId,
    String? propertyId,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['userId'],
      propertyId: json['propertyId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum AlertType {
  priceReduction,
  sold,
  newSimilar,
}

class PropertyAlert {
  final String id;
  final String userId;
  final String propertyId;
  final String propertyTitle;
  final AlertType type;
  final double? targetPrice;
  final DateTime createdAt;
  final bool isActive;

  PropertyAlert({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.propertyTitle,
    required this.type,
    this.targetPrice,
    required this.createdAt,
    this.isActive = true,
  });

  PropertyAlert copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? propertyTitle,
    AlertType? type,
    double? targetPrice,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return PropertyAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      type: type ?? this.type,
      targetPrice: targetPrice ?? this.targetPrice,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case AlertType.priceReduction:
        return 'Redução de Preço';
      case AlertType.sold:
        return 'Imóvel Vendido';
      case AlertType.newSimilar:
        return 'Imóvel Similar';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'type': type.name,
      'targetPrice': targetPrice,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory PropertyAlert.fromJson(Map<String, dynamic> json) {
    return PropertyAlert(
      id: json['id'],
      userId: json['userId'],
      propertyId: json['propertyId'],
      propertyTitle: json['propertyTitle'],
      type: AlertType.values.firstWhere((e) => e.name == json['type']),
      targetPrice: json['targetPrice']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}
