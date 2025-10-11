import 'dart:math';
import 'package:flutter/foundation.dart';
import 'property_model.dart';

/// Modelo para busca avançada
class SearchQuery {
  final String? text;
  final List<PropertyType>? propertyTypes;
  final List<String>? cities;
  final List<String>? neighborhoods;
  final double? minPrice;
  final double? maxPrice;
  final PropertyTransactionType? transactionType;
  final int? minBedrooms;
  final int? maxBedrooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minParkingSpaces;
  final int? maxParkingSpaces;
  final double? minArea;
  final double? maxArea;
  final double? maxCondominium;
  final double? maxIptu;
  final bool? acceptProposal;
  final bool? hasFinancing;
  final bool? isFeatured;
  final bool? isLaunch;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy;
  final bool? sortAscending;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final String? imageUrl; // Para busca por imagem
  final String? voiceQuery; // Para busca por voz

  const SearchQuery({
    this.text,
    this.propertyTypes,
    this.cities,
    this.neighborhoods,
    this.minPrice,
    this.maxPrice,
    this.transactionType,
    this.minBedrooms,
    this.maxBedrooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minParkingSpaces,
    this.maxParkingSpaces,
    this.minArea,
    this.maxArea,
    this.maxCondominium,
    this.maxIptu,
    this.acceptProposal,
    this.hasFinancing,
    this.isFeatured,
    this.isLaunch,
    this.startDate,
    this.endDate,
    this.sortBy,
    this.sortAscending,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.imageUrl,
    this.voiceQuery,
  });

  SearchQuery copyWith({
    String? text,
    List<PropertyType>? propertyTypes,
    List<String>? cities,
    List<String>? neighborhoods,
    double? minPrice,
    double? maxPrice,
    PropertyTransactionType? transactionType,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minParkingSpaces,
    int? maxParkingSpaces,
    double? minArea,
    double? maxArea,
    double? maxCondominium,
    double? maxIptu,
    bool? acceptProposal,
    bool? hasFinancing,
    bool? isFeatured,
    bool? isLaunch,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool? sortAscending,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? imageUrl,
    String? voiceQuery,
  }) {
    return SearchQuery(
      text: text ?? this.text,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      transactionType: transactionType ?? this.transactionType,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minParkingSpaces: minParkingSpaces ?? this.minParkingSpaces,
      maxParkingSpaces: maxParkingSpaces ?? this.maxParkingSpaces,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      maxCondominium: maxCondominium ?? this.maxCondominium,
      maxIptu: maxIptu ?? this.maxIptu,
      acceptProposal: acceptProposal ?? this.acceptProposal,
      hasFinancing: hasFinancing ?? this.hasFinancing,
      isFeatured: isFeatured ?? this.isFeatured,
      isLaunch: isLaunch ?? this.isLaunch,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      imageUrl: imageUrl ?? this.imageUrl,
      voiceQuery: voiceQuery ?? this.voiceQuery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'propertyTypes': propertyTypes?.map((e) => e.name).toList(),
      'cities': cities,
      'neighborhoods': neighborhoods,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'transactionType': transactionType?.name,
      'minBedrooms': minBedrooms,
      'maxBedrooms': maxBedrooms,
      'minBathrooms': minBathrooms,
      'maxBathrooms': maxBathrooms,
      'minParkingSpaces': minParkingSpaces,
      'maxParkingSpaces': maxParkingSpaces,
      'minArea': minArea,
      'maxArea': maxArea,
      'maxCondominium': maxCondominium,
      'maxIptu': maxIptu,
      'acceptProposal': acceptProposal,
      'hasFinancing': hasFinancing,
      'isFeatured': isFeatured,
      'isLaunch': isLaunch,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'sortBy': sortBy,
      'sortAscending': sortAscending,
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'imageUrl': imageUrl,
      'voiceQuery': voiceQuery,
    };
  }

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      text: json['text'],
      propertyTypes: json['propertyTypes'] != null
          ? (json['propertyTypes'] as List)
              .map((e) => PropertyType.values.firstWhere(
                    (type) => type.name == e,
                    orElse: () => PropertyType.house,
                  ))
              .toList()
          : null,
      cities: json['cities'] != null ? List<String>.from(json['cities']) : null,
      neighborhoods: json['neighborhoods'] != null
          ? List<String>.from(json['neighborhoods'])
          : null,
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      transactionType: json['transactionType'] != null
          ? PropertyTransactionType.values.firstWhere(
              (type) => type.name == json['transactionType'],
              orElse: () => PropertyTransactionType.sale,
            )
          : null,
      minBedrooms: json['minBedrooms'],
      maxBedrooms: json['maxBedrooms'],
      minBathrooms: json['minBathrooms'],
      maxBathrooms: json['maxBathrooms'],
      minParkingSpaces: json['minParkingSpaces'],
      maxParkingSpaces: json['maxParkingSpaces'],
      minArea: json['minArea']?.toDouble(),
      maxArea: json['maxArea']?.toDouble(),
      maxCondominium: json['maxCondominium']?.toDouble(),
      maxIptu: json['maxIptu']?.toDouble(),
      acceptProposal: json['acceptProposal'],
      hasFinancing: json['hasFinancing'],
      isFeatured: json['isFeatured'],
      isLaunch: json['isLaunch'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      sortBy: json['sortBy'],
      sortAscending: json['sortAscending'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      radiusKm: json['radiusKm']?.toDouble(),
      imageUrl: json['imageUrl'],
      voiceQuery: json['voiceQuery'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchQuery &&
        other.text == text &&
        listEquals(other.propertyTypes, propertyTypes) &&
        listEquals(other.cities, cities) &&
        listEquals(other.neighborhoods, neighborhoods) &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.transactionType == transactionType &&
        other.minBedrooms == minBedrooms &&
        other.maxBedrooms == maxBedrooms &&
        other.minBathrooms == minBathrooms &&
        other.maxBathrooms == maxBathrooms &&
        other.minParkingSpaces == minParkingSpaces &&
        other.maxParkingSpaces == maxParkingSpaces &&
        other.minArea == minArea &&
        other.maxArea == maxArea &&
        other.maxCondominium == maxCondominium &&
        other.maxIptu == maxIptu &&
        other.acceptProposal == acceptProposal &&
        other.hasFinancing == hasFinancing &&
        other.isFeatured == isFeatured &&
        other.isLaunch == isLaunch &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.sortBy == sortBy &&
        other.sortAscending == sortAscending &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radiusKm == radiusKm &&
        other.imageUrl == imageUrl &&
        other.voiceQuery == voiceQuery;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      text,
      propertyTypes,
      cities,
      neighborhoods,
      minPrice,
      maxPrice,
      transactionType,
      minBedrooms,
      maxBedrooms,
      minBathrooms,
      maxBathrooms,
      minParkingSpaces,
      maxParkingSpaces,
      minArea,
      maxArea,
      maxCondominium,
      maxIptu,
      acceptProposal,
      hasFinancing,
      isFeatured,
      isLaunch,
      startDate,
      endDate,
      sortBy,
      sortAscending,
      latitude,
      longitude,
      radiusKm,
      imageUrl,
      voiceQuery,
    ]);
  }
}

/// Modelo para histórico de busca
class SearchHistory {
  final String id;
  final String query;
  final SearchQuery searchQuery;
  final DateTime timestamp;
  final int resultCount;
  final String? userId;

  const SearchHistory({
    required this.id,
    required this.query,
    required this.searchQuery,
    required this.timestamp,
    required this.resultCount,
    this.userId,
  });

  SearchHistory copyWith({
    String? id,
    String? query,
    SearchQuery? searchQuery,
    DateTime? timestamp,
    int? resultCount,
    String? userId,
  }) {
    return SearchHistory(
      id: id ?? this.id,
      query: query ?? this.query,
      searchQuery: searchQuery ?? this.searchQuery,
      timestamp: timestamp ?? this.timestamp,
      resultCount: resultCount ?? this.resultCount,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'searchQuery': searchQuery.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
      'userId': userId,
    };
  }

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'],
      query: json['query'],
      searchQuery: SearchQuery.fromJson(json['searchQuery']),
      timestamp: DateTime.parse(json['timestamp']),
      resultCount: json['resultCount'],
      userId: json['userId'],
    );
  }
}

/// Modelo para sugestões de busca
class SearchSuggestion {
  final String text;
  final String type; // 'text', 'location', 'property_type'
  final int frequency;
  final DateTime lastUsed;

  const SearchSuggestion({
    required this.text,
    required this.type,
    required this.frequency,
    required this.lastUsed,
  });

  SearchSuggestion copyWith({
    String? text,
    String? type,
    int? frequency,
    DateTime? lastUsed,
  }) {
    return SearchSuggestion(
      text: text ?? this.text,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'frequency': frequency,
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      text: json['text'],
      type: json['type'],
      frequency: json['frequency'],
      lastUsed: DateTime.parse(json['lastUsed']),
    );
  }
}

/// Modelo para resultado de busca por imagem
class ImageSearchResult {
  final Property property;
  final double similarity;
  final List<String> matchingFeatures;

  const ImageSearchResult({
    required this.property,
    required this.similarity,
    required this.matchingFeatures,
  });

  Map<String, dynamic> toJson() {
    return {
      'property': property.toJson(),
      'similarity': similarity,
      'matchingFeatures': matchingFeatures,
    };
  }

  factory ImageSearchResult.fromJson(Map<String, dynamic> json) {
    return ImageSearchResult(
      property: Property.fromJson(json['property']),
      similarity: json['similarity'].toDouble(),
      matchingFeatures: List<String>.from(json['matchingFeatures']),
    );
  }
}

/// Modelo para localização geográfica
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? neighborhood;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.neighborhood,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'neighborhood': neighborhood,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      neighborhood: json['neighborhood'],
    );
  }

  /// Calcula a distância em quilômetros entre duas localizações
  double distanceTo(LocationData other) {
    const double earthRadius = 6371; // Raio da Terra em km
    
    final double lat1Rad = latitude * (3.14159265359 / 180);
    final double lat2Rad = other.latitude * (3.14159265359 / 180);
    final double deltaLatRad = (other.latitude - latitude) * (3.14159265359 / 180);
    final double deltaLonRad = (other.longitude - longitude) * (3.14159265359 / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }
}
