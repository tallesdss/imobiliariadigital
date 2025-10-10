enum PropertyType { house, apartment, commercial, land }

enum PropertyStatus { active, sold, archived, suspended }

enum PropertyTransactionType { sale, rent, daily }

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final PropertyType type;
  final PropertyStatus status;
  final PropertyTransactionType? transactionType;
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
    this.transactionType,
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
    PropertyTransactionType? transactionType,
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
      transactionType: transactionType ?? this.transactionType,
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
      'transactionType': transactionType?.name,
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
      title: json['titulo'] ?? json['title'] ?? '',
      description: json['descricao'] ?? json['description'] ?? '',
      price: _parsePrice(json['preco'] ?? json['price']),
      type: _parsePropertyType(json['tipo_imovel'] ?? json['type']),
      status: _parsePropertyStatus(json['status']),
      transactionType: _parseTransactionType(json['tipo_transacao'] ?? json['transactionType']),
      address: json['endereco'] ?? json['address'] ?? '',
      city: json['cidade'] ?? json['city'] ?? '',
      state: json['estado'] ?? json['state'] ?? '',
      zipCode: json['cep'] ?? json['zipCode'] ?? '',
      photos: List<String>.from(json['fotos'] ?? json['photos'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      attributes: Map<String, dynamic>.from(json['atributos'] ?? json['attributes'] ?? {}),
      realtorId: json['corretor_id'] ?? json['realtorId'] ?? '',
      realtorName: json['nome_corretor'] ?? json['realtorName'] ?? '',
      realtorPhone: json['telefone_corretor'] ?? json['realtorPhone'] ?? '',
      adminContact: json['contato_admin'] ?? json['adminContact'] ?? '',
      createdAt: _parseDateTime(json['data_criacao'] ?? json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['data_atualizacao'] ?? json['updatedAt'] ?? json['updated_at']),
      isFeatured: json['destaque'] ?? json['isFeatured'] ?? false,
      isLaunch: json['lancamento'] ?? json['isLaunch'] ?? false,
    );
  }

  static PropertyType _parsePropertyType(dynamic typeValue) {
    if (typeValue == null) return PropertyType.house;
    
    String typeStr = typeValue.toString().toLowerCase();
    switch (typeStr) {
      case 'casa':
      case 'house':
        return PropertyType.house;
      case 'apartamento':
      case 'apartment':
        return PropertyType.apartment;
      case 'comercial':
      case 'commercial':
        return PropertyType.commercial;
      case 'terreno':
      case 'land':
        return PropertyType.land;
      default:
        return PropertyType.house;
    }
  }

  static PropertyStatus _parsePropertyStatus(dynamic statusValue) {
    if (statusValue == null) return PropertyStatus.active;
    
    String statusStr = statusValue.toString().toLowerCase();
    switch (statusStr) {
      case 'ativo':
      case 'active':
        return PropertyStatus.active;
      case 'vendido':
      case 'sold':
        return PropertyStatus.sold;
      case 'arquivado':
      case 'archived':
        return PropertyStatus.archived;
      case 'suspenso':
      case 'suspended':
        return PropertyStatus.suspended;
      default:
        return PropertyStatus.active;
    }
  }

  static PropertyTransactionType? _parseTransactionType(dynamic transactionValue) {
    if (transactionValue == null) return null;
    
    String transactionStr = transactionValue.toString().toLowerCase();
    switch (transactionStr) {
      case 'venda':
      case 'sale':
        return PropertyTransactionType.sale;
      case 'aluguel':
      case 'rent':
        return PropertyTransactionType.rent;
      case 'temporada':
      case 'diaria':
      case 'daily':
        return PropertyTransactionType.daily;
      default:
        return null;
    }
  }

  static double _parsePrice(dynamic priceValue) {
    if (priceValue == null) return 0.0;
    
    if (priceValue is num) {
      return priceValue.toDouble();
    }
    
    if (priceValue is String) {
      try {
        return double.parse(priceValue);
      } catch (e) {
        return 0.0;
      }
    }
    
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    if (dateValue is DateTime) {
      return dateValue;
    }
    
    return DateTime.now();
  }
}
