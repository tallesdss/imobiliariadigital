import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para alertas de imóveis
class PropertyAlert {
  final String id;
  final String userId;
  final String? propertyId; // null para alertas gerais
  final AlertType type;
  final AlertCriteria criteria;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int triggerCount;
  final NotificationSettings notificationSettings;

  PropertyAlert({
    required this.id,
    required this.userId,
    this.propertyId,
    required this.type,
    required this.criteria,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
    this.triggerCount = 0,
    required this.notificationSettings,
  });

  factory PropertyAlert.fromMap(Map<String, dynamic> map) {
    return PropertyAlert(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'],
      type: AlertType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AlertType.priceDrop,
      ),
      criteria: AlertCriteria.fromMap(map['criteria'] ?? {}),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastTriggered: (map['lastTriggered'] as Timestamp?)?.toDate(),
      triggerCount: map['triggerCount'] ?? 0,
      notificationSettings: NotificationSettings.fromMap(
        map['notificationSettings'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'type': type.name,
      'criteria': criteria.toMap(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTriggered': lastTriggered != null 
          ? Timestamp.fromDate(lastTriggered!) 
          : null,
      'triggerCount': triggerCount,
      'notificationSettings': notificationSettings.toMap(),
    };
  }

  PropertyAlert copyWith({
    String? id,
    String? userId,
    String? propertyId,
    AlertType? type,
    AlertCriteria? criteria,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
    int? triggerCount,
    NotificationSettings? notificationSettings,
  }) {
    return PropertyAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      type: type ?? this.type,
      criteria: criteria ?? this.criteria,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      triggerCount: triggerCount ?? this.triggerCount,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

/// Tipos de alertas disponíveis
enum AlertType {
  priceDrop, // Redução de preço
  statusChange, // Mudança de status (vendido, alugado)
  newProperty, // Novo imóvel que atende critérios
  custom, // Alerta personalizado
}

/// Critérios para alertas
class AlertCriteria {
  final double? maxPrice;
  final double? minPrice;
  final String? city;
  final String? neighborhood;
  final AlertPropertyType? propertyType;
  final int? minBedrooms;
  final int? maxBedrooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final double? minArea;
  final double? maxArea;
  final bool? hasGarage;
  final bool? acceptsProposal;
  final bool? hasFinancing;
  final double? maxCondominium;
  final double? maxIptu;
  final List<String>? keywords; // Palavras-chave para busca

  AlertCriteria({
    this.maxPrice,
    this.minPrice,
    this.city,
    this.neighborhood,
    this.propertyType,
    this.minBedrooms,
    this.maxBedrooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minArea,
    this.maxArea,
    this.hasGarage,
    this.acceptsProposal,
    this.hasFinancing,
    this.maxCondominium,
    this.maxIptu,
    this.keywords,
  });

  factory AlertCriteria.fromMap(Map<String, dynamic> map) {
    return AlertCriteria(
      maxPrice: map['maxPrice']?.toDouble(),
      minPrice: map['minPrice']?.toDouble(),
      city: map['city'],
      neighborhood: map['neighborhood'],
      propertyType: map['propertyType'] != null
          ? AlertPropertyType.values.firstWhere(
              (e) => e.name == map['propertyType'],
              orElse: () => AlertPropertyType.apartment,
            )
          : null,
      minBedrooms: map['minBedrooms'],
      maxBedrooms: map['maxBedrooms'],
      minBathrooms: map['minBathrooms'],
      maxBathrooms: map['maxBathrooms'],
      minArea: map['minArea']?.toDouble(),
      maxArea: map['maxArea']?.toDouble(),
      hasGarage: map['hasGarage'],
      acceptsProposal: map['acceptsProposal'],
      hasFinancing: map['hasFinancing'],
      maxCondominium: map['maxCondominium']?.toDouble(),
      maxIptu: map['maxIptu']?.toDouble(),
      keywords: map['keywords'] != null 
          ? List<String>.from(map['keywords']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maxPrice': maxPrice,
      'minPrice': minPrice,
      'city': city,
      'neighborhood': neighborhood,
      'propertyType': propertyType?.name,
      'minBedrooms': minBedrooms,
      'maxBedrooms': maxBedrooms,
      'minBathrooms': minBathrooms,
      'maxBathrooms': maxBathrooms,
      'minArea': minArea,
      'maxArea': maxArea,
      'hasGarage': hasGarage,
      'acceptsProposal': acceptsProposal,
      'hasFinancing': hasFinancing,
      'maxCondominium': maxCondominium,
      'maxIptu': maxIptu,
      'keywords': keywords,
    };
  }

  /// Verifica se um imóvel atende aos critérios do alerta
  bool matchesProperty(Map<String, dynamic> property) {
    // Verificar preço
    final price = property['price']?.toDouble();
    if (price != null) {
      if (maxPrice != null && price > maxPrice!) return false;
      if (minPrice != null && price < minPrice!) return false;
    }

    // Verificar localização
    if (city != null && property['city'] != city) return false;
    if (neighborhood != null && property['neighborhood'] != neighborhood) {
      return false;
    }

    // Verificar tipo de imóvel
    if (propertyType != null && property['type'] != propertyType!.name) {
      return false;
    }

    // Verificar quartos
    final bedrooms = property['bedrooms'];
    if (bedrooms != null) {
      if (minBedrooms != null && bedrooms < minBedrooms!) return false;
      if (maxBedrooms != null && bedrooms > maxBedrooms!) return false;
    }

    // Verificar banheiros
    final bathrooms = property['bathrooms'];
    if (bathrooms != null) {
      if (minBathrooms != null && bathrooms < minBathrooms!) return false;
      if (maxBathrooms != null && bathrooms > maxBathrooms!) return false;
    }

    // Verificar área
    final area = property['area']?.toDouble();
    if (area != null) {
      if (minArea != null && area < minArea!) return false;
      if (maxArea != null && area > maxArea!) return false;
    }

    // Verificar características especiais
    if (hasGarage != null && property['hasGarage'] != hasGarage) return false;
    if (acceptsProposal != null && property['acceptsProposal'] != acceptsProposal) {
      return false;
    }
    if (hasFinancing != null && property['hasFinancing'] != hasFinancing) {
      return false;
    }

    // Verificar condomínio
    final condominium = property['condominium']?.toDouble();
    if (condominium != null && maxCondominium != null && 
        condominium > maxCondominium!) {
      return false;
    }

    // Verificar IPTU
    final iptu = property['iptu']?.toDouble();
    if (iptu != null && maxIptu != null && iptu > maxIptu!) return false;

    // Verificar palavras-chave
    if (keywords != null && keywords!.isNotEmpty) {
      final title = (property['title'] ?? '').toLowerCase();
      final description = (property['description'] ?? '').toLowerCase();
      final hasKeyword = keywords!.any((keyword) =>
          title.contains(keyword.toLowerCase()) ||
          description.contains(keyword.toLowerCase()));
      if (!hasKeyword) return false;
    }

    return true;
  }
}

/// Configurações de notificação
class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final List<int> allowedHours; // Horários permitidos (0-23)
  final List<int> allowedDays; // Dias da semana permitidos (1-7)
  final int maxNotificationsPerDay;
  final bool quietMode; // Modo silencioso

  NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
    this.allowedHours = const [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
    this.allowedDays = const [1, 2, 3, 4, 5, 6, 7], // Todos os dias
    this.maxNotificationsPerDay = 10,
    this.quietMode = false,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? false,
      smsEnabled: map['smsEnabled'] ?? false,
      allowedHours: map['allowedHours'] != null
          ? List<int>.from(map['allowedHours'])
          : const [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
      allowedDays: map['allowedDays'] != null
          ? List<int>.from(map['allowedDays'])
          : const [1, 2, 3, 4, 5, 6, 7],
      maxNotificationsPerDay: map['maxNotificationsPerDay'] ?? 10,
      quietMode: map['quietMode'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'allowedHours': allowedHours,
      'allowedDays': allowedDays,
      'maxNotificationsPerDay': maxNotificationsPerDay,
      'quietMode': quietMode,
    };
  }

  /// Verifica se é permitido enviar notificação no momento atual
  bool canSendNotification() {
    if (quietMode) return false;
    
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday;
    
    return allowedHours.contains(currentHour) && 
           allowedDays.contains(currentDay);
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    List<int>? allowedHours,
    List<int>? allowedDays,
    int? maxNotificationsPerDay,
    bool? quietMode,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      allowedHours: allowedHours ?? this.allowedHours,
      allowedDays: allowedDays ?? this.allowedDays,
      maxNotificationsPerDay: maxNotificationsPerDay ?? this.maxNotificationsPerDay,
      quietMode: quietMode ?? this.quietMode,
    );
  }
}

/// Modelo para histórico de alertas
class AlertHistory {
  final String id;
  final String alertId;
  final String userId;
  final String propertyId;
  final AlertType type;
  final String message;
  final DateTime triggeredAt;
  final bool wasRead;
  final Map<String, dynamic>? metadata;

  AlertHistory({
    required this.id,
    required this.alertId,
    required this.userId,
    required this.propertyId,
    required this.type,
    required this.message,
    required this.triggeredAt,
    this.wasRead = false,
    this.metadata,
  });

  factory AlertHistory.fromMap(Map<String, dynamic> map) {
    return AlertHistory(
      id: map['id'] ?? '',
      alertId: map['alertId'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AlertType.priceDrop,
      ),
      message: map['message'] ?? '',
      triggeredAt: (map['triggeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wasRead: map['wasRead'] ?? false,
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alertId': alertId,
      'userId': userId,
      'propertyId': propertyId,
      'type': type.name,
      'message': message,
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      'wasRead': wasRead,
      'metadata': metadata,
    };
  }

  // Getters para compatibilidade
  String get title => message;
  bool get isRead => wasRead;
  
  String get typeDisplayName {
    switch (type) {
      case AlertType.priceDrop:
        return 'Redução de Preço';
      case AlertType.statusChange:
        return 'Mudança de Status';
      case AlertType.newProperty:
        return 'Novo Imóvel';
      case AlertType.custom:
        return 'Alerta Personalizado';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(triggeredAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora';
    }
  }
}

/// Tipos de propriedade para alertas
enum AlertPropertyType {
  apartment,
  house,
  commercial,
  land,
  rural,
}
