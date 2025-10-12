enum PropertyType { house, apartment, commercial, land }

enum PropertyStatus { active, sold, archived, suspended }

enum PropertyTransactionType { sale, rent, daily }

enum PropertyCategory { 
  residential, 
  commercial, 
  industrial, 
  rural, 
  luxury, 
  investment, 
  vacation, 
  student 
}

enum PropertyTag { 
  // Tags de destaque
  featured, 
  launch, 
  newProperty, 
  hotDeal, 
  exclusive,
  
  // Tags de características
  furnished, 
  unfurnished, 
  petFriendly, 
  hasPool, 
  hasGym, 
  hasSecurity, 
  hasGarage, 
  hasGarden, 
  hasBalcony, 
  hasElevator,
  
  // Tags de localização
  nearMetro, 
  nearSchool, 
  nearHospital, 
  nearShopping, 
  beachfront, 
  downtown, 
  quietArea,
  
  // Tags de financiamento
  acceptsProposal, 
  hasFinancing, 
  cashOnly, 
  rentToOwn,
  
  // Tags de urgência
  urgent, 
  priceReduced, 
  motivatedSeller,
  
  // Tags especiais
  heritage, 
  ecoFriendly, 
  smartHome, 
  renovated, 
  needsRenovation
}

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final PropertyType type;
  final PropertyStatus status;
  final PropertyTransactionType? transactionType;
  final PropertyCategory? category;
  final List<PropertyTag> tags;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? neighborhood;
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
    this.category,
    this.tags = const [],
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.neighborhood,
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
    PropertyCategory? category,
    List<PropertyTag>? tags,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? neighborhood,
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
      category: category ?? this.category,
      tags: tags ?? this.tags,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      neighborhood: neighborhood ?? this.neighborhood,
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

  String get categoryDisplayName {
    if (category == null) return 'Não especificado';
    switch (category!) {
      case PropertyCategory.residential:
        return 'Residencial';
      case PropertyCategory.commercial:
        return 'Comercial';
      case PropertyCategory.industrial:
        return 'Industrial';
      case PropertyCategory.rural:
        return 'Rural';
      case PropertyCategory.luxury:
        return 'Luxo';
      case PropertyCategory.investment:
        return 'Investimento';
      case PropertyCategory.vacation:
        return 'Férias';
      case PropertyCategory.student:
        return 'Estudante';
    }
  }

  List<String> get tagDisplayNames {
    return tags.map((tag) => _getTagDisplayName(tag)).toList();
  }

  String _getTagDisplayName(PropertyTag tag) {
    switch (tag) {
      // Tags de destaque
      case PropertyTag.featured:
        return 'Destaque';
      case PropertyTag.launch:
        return 'Lançamento';
      case PropertyTag.newProperty:
        return 'Novo';
      case PropertyTag.hotDeal:
        return 'Oferta Quente';
      case PropertyTag.exclusive:
        return 'Exclusivo';
      
      // Tags de características
      case PropertyTag.furnished:
        return 'Mobiliado';
      case PropertyTag.unfurnished:
        return 'Não Mobiliado';
      case PropertyTag.petFriendly:
        return 'Pet Friendly';
      case PropertyTag.hasPool:
        return 'Com Piscina';
      case PropertyTag.hasGym:
        return 'Com Academia';
      case PropertyTag.hasSecurity:
        return 'Com Segurança';
      case PropertyTag.hasGarage:
        return 'Com Garagem';
      case PropertyTag.hasGarden:
        return 'Com Jardim';
      case PropertyTag.hasBalcony:
        return 'Com Varanda';
      case PropertyTag.hasElevator:
        return 'Com Elevador';
      
      // Tags de localização
      case PropertyTag.nearMetro:
        return 'Próximo ao Metrô';
      case PropertyTag.nearSchool:
        return 'Próximo à Escola';
      case PropertyTag.nearHospital:
        return 'Próximo ao Hospital';
      case PropertyTag.nearShopping:
        return 'Próximo ao Shopping';
      case PropertyTag.beachfront:
        return 'Frente para o Mar';
      case PropertyTag.downtown:
        return 'Centro';
      case PropertyTag.quietArea:
        return 'Área Tranquila';
      
      // Tags de financiamento
      case PropertyTag.acceptsProposal:
        return 'Aceita Proposta';
      case PropertyTag.hasFinancing:
        return 'Tem Financiamento';
      case PropertyTag.cashOnly:
        return 'Apenas à Vista';
      case PropertyTag.rentToOwn:
        return 'Renda para Compra';
      
      // Tags de urgência
      case PropertyTag.urgent:
        return 'Urgente';
      case PropertyTag.priceReduced:
        return 'Preço Reduzido';
      case PropertyTag.motivatedSeller:
        return 'Vendedor Motivado';
      
      // Tags especiais
      case PropertyTag.heritage:
        return 'Patrimônio';
      case PropertyTag.ecoFriendly:
        return 'Eco-Friendly';
      case PropertyTag.smartHome:
        return 'Casa Inteligente';
      case PropertyTag.renovated:
        return 'Reformado';
      case PropertyTag.needsRenovation:
        return 'Precisa Reforma';
    }
  }

  // Getters para propriedades comuns
  int get bedrooms => attributes['bedrooms'] ?? 0;
  int get bathrooms => attributes['bathrooms'] ?? 0;
  double get area => (attributes['area'] ?? 0).toDouble();
  int get parkingSpaces => attributes['parkingSpaces'] ?? 0;
  double get condominium => (attributes['condominium'] ?? 0).toDouble();
  double get iptu => (attributes['iptu'] ?? 0).toDouble();
  bool get hasGarage => attributes['hasGarage'] ?? false;
  bool get acceptsProposal => attributes['acceptsProposal'] ?? false;
  bool get hasFinancing => attributes['hasFinancing'] ?? false;
  bool get furnished => attributes['furnished'] ?? false;
  bool get petFriendly => attributes['petFriendly'] ?? false;
  bool get hasSecurity => attributes['hasSecurity'] ?? false;
  bool get hasSwimmingPool => attributes['hasSwimmingPool'] ?? false;
  bool get hasGym => attributes['hasGym'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'type': type.name,
      'status': status.name,
      'transactionType': transactionType?.name,
      'category': category?.name,
      'tags': tags.map((tag) => tag.name).toList(),
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'neighborhood': neighborhood,
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
      category: _parsePropertyCategory(json['categoria'] ?? json['category']),
      tags: _parsePropertyTags(json['tags'] ?? []),
      address: json['endereco'] ?? json['address'] ?? '',
      city: json['cidade'] ?? json['city'] ?? '',
      state: json['estado'] ?? json['state'] ?? '',
      zipCode: json['cep'] ?? json['zipCode'] ?? '',
      neighborhood: json['bairro'] ?? json['neighborhood'],
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

  static PropertyCategory? _parsePropertyCategory(dynamic categoryValue) {
    if (categoryValue == null) return null;
    
    String categoryStr = categoryValue.toString().toLowerCase();
    switch (categoryStr) {
      case 'residential':
      case 'residencial':
        return PropertyCategory.residential;
      case 'commercial':
      case 'comercial':
        return PropertyCategory.commercial;
      case 'industrial':
        return PropertyCategory.industrial;
      case 'rural':
        return PropertyCategory.rural;
      case 'luxury':
      case 'luxo':
        return PropertyCategory.luxury;
      case 'investment':
      case 'investimento':
        return PropertyCategory.investment;
      case 'vacation':
      case 'ferias':
        return PropertyCategory.vacation;
      case 'student':
      case 'estudante':
        return PropertyCategory.student;
      default:
        return null;
    }
  }

  static List<PropertyTag> _parsePropertyTags(dynamic tagsValue) {
    if (tagsValue == null) return [];
    
    if (tagsValue is List) {
      return tagsValue.map((tag) => _parsePropertyTag(tag)).where((tag) => tag != null).cast<PropertyTag>().toList();
    }
    
    return [];
  }

  static PropertyTag? _parsePropertyTag(dynamic tagValue) {
    if (tagValue == null) return null;
    
    String tagStr = tagValue.toString().toLowerCase();
    switch (tagStr) {
      // Tags de destaque
      case 'featured':
      case 'destaque':
        return PropertyTag.featured;
      case 'launch':
      case 'lancamento':
        return PropertyTag.launch;
      case 'newproperty':
      case 'new_property':
      case 'novo':
        return PropertyTag.newProperty;
      case 'hotdeal':
      case 'hot_deal':
      case 'oferta_quente':
        return PropertyTag.hotDeal;
      case 'exclusive':
      case 'exclusivo':
        return PropertyTag.exclusive;
      
      // Tags de características
      case 'furnished':
      case 'mobiliado':
        return PropertyTag.furnished;
      case 'unfurnished':
      case 'nao_mobiliado':
        return PropertyTag.unfurnished;
      case 'petfriendly':
      case 'pet_friendly':
        return PropertyTag.petFriendly;
      case 'haspool':
      case 'has_pool':
      case 'com_piscina':
        return PropertyTag.hasPool;
      case 'hasgym':
      case 'has_gym':
      case 'com_academia':
        return PropertyTag.hasGym;
      case 'hassecurity':
      case 'has_security':
      case 'com_seguranca':
        return PropertyTag.hasSecurity;
      case 'hasgarage':
      case 'has_garage':
      case 'com_garagem':
        return PropertyTag.hasGarage;
      case 'hasgarden':
      case 'has_garden':
      case 'com_jardim':
        return PropertyTag.hasGarden;
      case 'hasbalcony':
      case 'has_balcony':
      case 'com_varanda':
        return PropertyTag.hasBalcony;
      case 'haselevator':
      case 'has_elevator':
      case 'com_elevador':
        return PropertyTag.hasElevator;
      
      // Tags de localização
      case 'nearmetro':
      case 'near_metro':
      case 'proximo_metro':
        return PropertyTag.nearMetro;
      case 'nearschool':
      case 'near_school':
      case 'proximo_escola':
        return PropertyTag.nearSchool;
      case 'nearhospital':
      case 'near_hospital':
      case 'proximo_hospital':
        return PropertyTag.nearHospital;
      case 'nearshopping':
      case 'near_shopping':
      case 'proximo_shopping':
        return PropertyTag.nearShopping;
      case 'beachfront':
      case 'frente_mar':
        return PropertyTag.beachfront;
      case 'downtown':
      case 'centro':
        return PropertyTag.downtown;
      case 'quietarea':
      case 'quiet_area':
      case 'area_tranquila':
        return PropertyTag.quietArea;
      
      // Tags de financiamento
      case 'acceptsproposal':
      case 'accepts_proposal':
      case 'aceita_proposta':
        return PropertyTag.acceptsProposal;
      case 'hasfinancing':
      case 'has_financing':
      case 'tem_financiamento':
        return PropertyTag.hasFinancing;
      case 'cashonly':
      case 'cash_only':
      case 'apenas_vista':
        return PropertyTag.cashOnly;
      case 'renttoown':
      case 'rent_to_own':
      case 'renda_compra':
        return PropertyTag.rentToOwn;
      
      // Tags de urgência
      case 'urgent':
      case 'urgente':
        return PropertyTag.urgent;
      case 'pricereduced':
      case 'price_reduced':
      case 'preco_reduzido':
        return PropertyTag.priceReduced;
      case 'motivatedseller':
      case 'motivated_seller':
      case 'vendedor_motivado':
        return PropertyTag.motivatedSeller;
      
      // Tags especiais
      case 'heritage':
      case 'patrimonio':
        return PropertyTag.heritage;
      case 'ecofriendly':
      case 'eco_friendly':
        return PropertyTag.ecoFriendly;
      case 'smarthome':
      case 'smart_home':
      case 'casa_inteligente':
        return PropertyTag.smartHome;
      case 'renovated':
      case 'reformado':
        return PropertyTag.renovated;
      case 'needsrenovation':
      case 'needs_renovation':
      case 'precisa_reforma':
        return PropertyTag.needsRenovation;
      
      default:
        return null;
    }
  }
}
