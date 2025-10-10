enum NotificationType {
  propertyUpdate,
  newMessage,
  favoriteMatch,
  systemAlert,
  appointmentReminder,
  priceChange,
  newProperty,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final String? userId;
  final String? propertyId;
  final String? conversationId;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.medium,
    this.userId,
    this.propertyId,
    this.conversationId,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    String? userId,
    String? propertyId,
    String? conversationId,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      conversationId: conversationId ?? this.conversationId,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'userId': userId,
      'propertyId': propertyId,
      'conversationId': conversationId,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      userId: json['userId'],
      propertyId: json['propertyId'],
      conversationId: json['conversationId'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'])
          : null,
    );
  }

  // Métodos auxiliares
  String get typeDisplayName {
    switch (type) {
      case NotificationType.propertyUpdate:
        return 'Atualização de Imóvel';
      case NotificationType.newMessage:
        return 'Nova Mensagem';
      case NotificationType.favoriteMatch:
        return 'Imóvel Favorito';
      case NotificationType.systemAlert:
        return 'Alerta do Sistema';
      case NotificationType.appointmentReminder:
        return 'Lembrete de Agendamento';
      case NotificationType.priceChange:
        return 'Mudança de Preço';
      case NotificationType.newProperty:
        return 'Novo Imóvel';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case NotificationPriority.low:
        return 'Baixa';
      case NotificationPriority.medium:
        return 'Média';
      case NotificationPriority.high:
        return 'Alta';
      case NotificationPriority.urgent:
        return 'Urgente';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'Agora';
    }
  }
}
