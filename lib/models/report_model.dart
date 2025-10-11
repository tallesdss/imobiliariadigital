class RealtorReport {
  final String id;
  final String realtorId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalProperties;
  final int activeProperties;
  final int soldProperties;
  final int archivedProperties;
  final double conversionRate;
  final double totalRevenue;
  final double averagePrice;
  final int totalViews;
  final int totalLeads;
  final int convertedLeads;
  final double leadConversionRate;
  final List<PropertyPerformance> topProperties;
  final List<MonthlyPerformance> monthlyData;

  RealtorReport({
    required this.id,
    required this.realtorId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalProperties,
    required this.activeProperties,
    required this.soldProperties,
    required this.archivedProperties,
    required this.conversionRate,
    required this.totalRevenue,
    required this.averagePrice,
    required this.totalViews,
    required this.totalLeads,
    required this.convertedLeads,
    required this.leadConversionRate,
    required this.topProperties,
    required this.monthlyData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'realtorId': realtorId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'totalProperties': totalProperties,
      'activeProperties': activeProperties,
      'soldProperties': soldProperties,
      'archivedProperties': archivedProperties,
      'conversionRate': conversionRate,
      'totalRevenue': totalRevenue,
      'averagePrice': averagePrice,
      'totalViews': totalViews,
      'totalLeads': totalLeads,
      'convertedLeads': convertedLeads,
      'leadConversionRate': leadConversionRate,
      'topProperties': topProperties.map((p) => p.toJson()).toList(),
      'monthlyData': monthlyData.map((m) => m.toJson()).toList(),
    };
  }

  factory RealtorReport.fromJson(Map<String, dynamic> json) {
    return RealtorReport(
      id: json['id'],
      realtorId: json['realtorId'],
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      totalProperties: json['totalProperties'],
      activeProperties: json['activeProperties'],
      soldProperties: json['soldProperties'],
      archivedProperties: json['archivedProperties'],
      conversionRate: json['conversionRate'].toDouble(),
      totalRevenue: json['totalRevenue'].toDouble(),
      averagePrice: json['averagePrice'].toDouble(),
      totalViews: json['totalViews'],
      totalLeads: json['totalLeads'],
      convertedLeads: json['convertedLeads'],
      leadConversionRate: json['leadConversionRate'].toDouble(),
      topProperties: (json['topProperties'] as List)
          .map((p) => PropertyPerformance.fromJson(p))
          .toList(),
      monthlyData: (json['monthlyData'] as List)
          .map((m) => MonthlyPerformance.fromJson(m))
          .toList(),
    );
  }
}

class PropertyPerformance {
  final String propertyId;
  final String title;
  final double price;
  final int views;
  final int leads;
  final bool isSold;
  final DateTime? soldDate;
  final double? soldPrice;

  PropertyPerformance({
    required this.propertyId,
    required this.title,
    required this.price,
    required this.views,
    required this.leads,
    required this.isSold,
    this.soldDate,
    this.soldPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'title': title,
      'price': price,
      'views': views,
      'leads': leads,
      'isSold': isSold,
      'soldDate': soldDate?.toIso8601String(),
      'soldPrice': soldPrice,
    };
  }

  factory PropertyPerformance.fromJson(Map<String, dynamic> json) {
    return PropertyPerformance(
      propertyId: json['propertyId'],
      title: json['title'],
      price: json['price'].toDouble(),
      views: json['views'],
      leads: json['leads'],
      isSold: json['isSold'],
      soldDate: json['soldDate'] != null ? DateTime.parse(json['soldDate']) : null,
      soldPrice: json['soldPrice']?.toDouble(),
    );
  }
}

class MonthlyPerformance {
  final int year;
  final int month;
  final int propertiesAdded;
  final int propertiesSold;
  final double revenue;
  final int views;
  final int leads;
  final double conversionRate;

  MonthlyPerformance({
    required this.year,
    required this.month,
    required this.propertiesAdded,
    required this.propertiesSold,
    required this.revenue,
    required this.views,
    required this.leads,
    required this.conversionRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'propertiesAdded': propertiesAdded,
      'propertiesSold': propertiesSold,
      'revenue': revenue,
      'views': views,
      'leads': leads,
      'conversionRate': conversionRate,
    };
  }

  factory MonthlyPerformance.fromJson(Map<String, dynamic> json) {
    return MonthlyPerformance(
      year: json['year'],
      month: json['month'],
      propertiesAdded: json['propertiesAdded'],
      propertiesSold: json['propertiesSold'],
      revenue: json['revenue'].toDouble(),
      views: json['views'],
      leads: json['leads'],
      conversionRate: json['conversionRate'].toDouble(),
    );
  }
}

class Goal {
  final String id;
  final String realtorId;
  final String title;
  final String description;
  final GoalType type;
  final double targetValue;
  final double currentValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DateTime? completedDate;

  Goal({
    required this.id,
    required this.realtorId,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.completedDate,
  });

  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue * 100).clamp(0, 100);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'realtorId': realtorId,
      'title': title,
      'description': description,
      'type': type.toString(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      realtorId: json['realtorId'],
      title: json['title'],
      description: json['description'],
      type: GoalType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => GoalType.propertiesSold,
      ),
      targetValue: json['targetValue'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isCompleted: json['isCompleted'] ?? false,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
    );
  }
}

enum GoalType {
  propertiesSold,
  revenue,
  leads,
  views,
  conversionRate,
}

class SupportTicket {
  final String id;
  final String realtorId;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TicketMessage> messages;

  SupportTicket({
    required this.id,
    required this.realtorId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.messages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'realtorId': realtorId,
      'title': title,
      'description': description,
      'category': category.toString(),
      'priority': priority.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      realtorId: json['realtorId'],
      title: json['title'],
      description: json['description'],
      category: TicketCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => TicketCategory.technical,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TicketStatus.open,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      messages: (json['messages'] as List?)
          ?.map((m) => TicketMessage.fromJson(m))
          .toList() ?? [],
    );
  }
}

class TicketMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime createdAt;
  final bool isFromSupport;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.createdAt,
    this.isFromSupport = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isFromSupport': isFromSupport,
    };
  }

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'],
      ticketId: json['ticketId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isFromSupport: json['isFromSupport'] ?? false,
    );
  }
}

enum TicketCategory {
  technical,
  commercial,
  financial,
  feature,
  bug,
  other,
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent,
}

enum TicketStatus {
  open,
  inProgress,
  waitingForUser,
  resolved,
  closed,
}
