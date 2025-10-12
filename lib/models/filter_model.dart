import 'property_model.dart';

enum TransactionType { sale, rent, daily }

// Filtros para usuários
class UserPropertyFilters {
  final double? minPrice;
  final double? maxPrice;
  final TransactionType? transactionType;
  final double? maxCondominium;
  final double? maxIptu;
  final bool showOnlyWithPrice;
  final bool acceptProposal;
  final bool hasFinancing;
  final List<String> priceRanges;
  final List<PropertyType> propertyTypes;
  final List<String> cities;
  final List<String> neighborhoods;
  final int? minBedrooms;
  final int? maxBedrooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minParkingSpaces;
  final int? maxParkingSpaces;
  final double? minArea;
  final double? maxArea;
  final bool furnished;
  final bool petFriendly;
  final bool hasSecurity;
  final bool hasSwimmingPool;
  final bool hasGym;
  final List<String> savedFilters;

  const UserPropertyFilters({
    this.minPrice,
    this.maxPrice,
    this.transactionType,
    this.maxCondominium,
    this.maxIptu,
    this.showOnlyWithPrice = false,
    this.acceptProposal = false,
    this.hasFinancing = false,
    this.priceRanges = const [],
    this.propertyTypes = const [],
    this.cities = const [],
    this.neighborhoods = const [],
    this.minBedrooms,
    this.maxBedrooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minParkingSpaces,
    this.maxParkingSpaces,
    this.minArea,
    this.maxArea,
    this.furnished = false,
    this.petFriendly = false,
    this.hasSecurity = false,
    this.hasSwimmingPool = false,
    this.hasGym = false,
    this.savedFilters = const [],
  });

  UserPropertyFilters copyWith({
    double? minPrice,
    double? maxPrice,
    TransactionType? transactionType,
    double? maxCondominium,
    double? maxIptu,
    bool? showOnlyWithPrice,
    bool? acceptProposal,
    bool? hasFinancing,
    List<String>? priceRanges,
    List<PropertyType>? propertyTypes,
    List<String>? cities,
    List<String>? neighborhoods,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minParkingSpaces,
    int? maxParkingSpaces,
    double? minArea,
    double? maxArea,
    bool? furnished,
    bool? petFriendly,
    bool? hasSecurity,
    bool? hasSwimmingPool,
    bool? hasGym,
    List<String>? savedFilters,
  }) {
    return UserPropertyFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      transactionType: transactionType ?? this.transactionType,
      maxCondominium: maxCondominium ?? this.maxCondominium,
      maxIptu: maxIptu ?? this.maxIptu,
      showOnlyWithPrice: showOnlyWithPrice ?? this.showOnlyWithPrice,
      acceptProposal: acceptProposal ?? this.acceptProposal,
      hasFinancing: hasFinancing ?? this.hasFinancing,
      priceRanges: priceRanges ?? this.priceRanges,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minParkingSpaces: minParkingSpaces ?? this.minParkingSpaces,
      maxParkingSpaces: maxParkingSpaces ?? this.maxParkingSpaces,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      furnished: furnished ?? this.furnished,
      petFriendly: petFriendly ?? this.petFriendly,
      hasSecurity: hasSecurity ?? this.hasSecurity,
      hasSwimmingPool: hasSwimmingPool ?? this.hasSwimmingPool,
      hasGym: hasGym ?? this.hasGym,
      savedFilters: savedFilters ?? this.savedFilters,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        transactionType != null ||
        maxCondominium != null ||
        maxIptu != null ||
        showOnlyWithPrice ||
        acceptProposal ||
        hasFinancing ||
        priceRanges.isNotEmpty ||
        propertyTypes.isNotEmpty ||
        cities.isNotEmpty ||
        neighborhoods.isNotEmpty ||
        minBedrooms != null ||
        maxBedrooms != null ||
        minBathrooms != null ||
        maxBathrooms != null ||
        minParkingSpaces != null ||
        maxParkingSpaces != null ||
        minArea != null ||
        maxArea != null ||
        furnished ||
        petFriendly ||
        hasSecurity ||
        hasSwimmingPool ||
        hasGym;
  }

  UserPropertyFilters clear() {
    return const UserPropertyFilters();
  }
}

// Filtros para corretores
class RealtorPropertyFilters {
  final List<PropertyStatus> statuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? lastUpdateStart;
  final DateTime? lastUpdateEnd;
  final List<PropertyType> propertyTypes;
  final List<String> cities;
  final List<String> neighborhoods;
  final double? minPrice;
  final double? maxPrice;
  final TransactionType? transactionType;
  final bool showOnlyFeatured;
  final bool showOnlyLaunches;
  final String sortBy; // 'price', 'date', 'status', 'interest'
  final bool sortAscending;
  final int? minViews;
  final int? minLeads;

  const RealtorPropertyFilters({
    this.statuses = const [],
    this.startDate,
    this.endDate,
    this.lastUpdateStart,
    this.lastUpdateEnd,
    this.propertyTypes = const [],
    this.cities = const [],
    this.neighborhoods = const [],
    this.minPrice,
    this.maxPrice,
    this.transactionType,
    this.showOnlyFeatured = false,
    this.showOnlyLaunches = false,
    this.sortBy = 'date',
    this.sortAscending = false,
    this.minViews,
    this.minLeads,
  });

  RealtorPropertyFilters copyWith({
    List<PropertyStatus>? statuses,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastUpdateStart,
    DateTime? lastUpdateEnd,
    List<PropertyType>? propertyTypes,
    List<String>? cities,
    List<String>? neighborhoods,
    double? minPrice,
    double? maxPrice,
    TransactionType? transactionType,
    bool? showOnlyFeatured,
    bool? showOnlyLaunches,
    String? sortBy,
    bool? sortAscending,
    int? minViews,
    int? minLeads,
  }) {
    return RealtorPropertyFilters(
      statuses: statuses ?? this.statuses,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastUpdateStart: lastUpdateStart ?? this.lastUpdateStart,
      lastUpdateEnd: lastUpdateEnd ?? this.lastUpdateEnd,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      transactionType: transactionType ?? this.transactionType,
      showOnlyFeatured: showOnlyFeatured ?? this.showOnlyFeatured,
      showOnlyLaunches: showOnlyLaunches ?? this.showOnlyLaunches,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      minViews: minViews ?? this.minViews,
      minLeads: minLeads ?? this.minLeads,
    );
  }

  bool get hasActiveFilters {
    return statuses.isNotEmpty ||
        startDate != null ||
        endDate != null ||
        lastUpdateStart != null ||
        lastUpdateEnd != null ||
        propertyTypes.isNotEmpty ||
        cities.isNotEmpty ||
        neighborhoods.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        transactionType != null ||
        showOnlyFeatured ||
        showOnlyLaunches ||
        sortBy != 'date' ||
        !sortAscending ||
        minViews != null ||
        minLeads != null;
  }

  RealtorPropertyFilters clear() {
    return const RealtorPropertyFilters();
  }
}

// Filtros para administradores
class AdminPropertyFilters {
  final List<String> realtorIds;
  final List<PropertyStatus> statuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<PropertyType> propertyTypes;
  final List<String> cities;
  final List<String> neighborhoods;
  final double? minPrice;
  final double? maxPrice;
  final TransactionType? transactionType;
  final bool showOnlyFeatured;
  final bool showOnlyLaunches;
  final String sortBy; // 'price', 'date', 'status', 'realtor', 'performance'
  final bool sortAscending;
  final int? minViews;
  final int? minLeads;
  final String? performanceFilter; // 'high', 'medium', 'low'

  const AdminPropertyFilters({
    this.realtorIds = const [],
    this.statuses = const [],
    this.startDate,
    this.endDate,
    this.propertyTypes = const [],
    this.cities = const [],
    this.neighborhoods = const [],
    this.minPrice,
    this.maxPrice,
    this.transactionType,
    this.showOnlyFeatured = false,
    this.showOnlyLaunches = false,
    this.sortBy = 'date',
    this.sortAscending = false,
    this.minViews,
    this.minLeads,
    this.performanceFilter,
  });

  AdminPropertyFilters copyWith({
    List<String>? realtorIds,
    List<PropertyStatus>? statuses,
    DateTime? startDate,
    DateTime? endDate,
    List<PropertyType>? propertyTypes,
    List<String>? cities,
    List<String>? neighborhoods,
    double? minPrice,
    double? maxPrice,
    TransactionType? transactionType,
    bool? showOnlyFeatured,
    bool? showOnlyLaunches,
    String? sortBy,
    bool? sortAscending,
    int? minViews,
    int? minLeads,
    String? performanceFilter,
  }) {
    return AdminPropertyFilters(
      realtorIds: realtorIds ?? this.realtorIds,
      statuses: statuses ?? this.statuses,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      transactionType: transactionType ?? this.transactionType,
      showOnlyFeatured: showOnlyFeatured ?? this.showOnlyFeatured,
      showOnlyLaunches: showOnlyLaunches ?? this.showOnlyLaunches,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      minViews: minViews ?? this.minViews,
      minLeads: minLeads ?? this.minLeads,
      performanceFilter: performanceFilter ?? this.performanceFilter,
    );
  }

  bool get hasActiveFilters {
    return realtorIds.isNotEmpty ||
        statuses.isNotEmpty ||
        startDate != null ||
        endDate != null ||
        propertyTypes.isNotEmpty ||
        cities.isNotEmpty ||
        neighborhoods.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        transactionType != null ||
        showOnlyFeatured ||
        showOnlyLaunches ||
        sortBy != 'date' ||
        !sortAscending ||
        minViews != null ||
        minLeads != null ||
        performanceFilter != null;
  }

  AdminPropertyFilters clear() {
    return const AdminPropertyFilters();
  }
}

// Classe base para compatibilidade com código existente
class PropertyFilters {
  final double? minPrice;
  final double? maxPrice;
  final TransactionType? transactionType;
  final double? maxCondominium;
  final double? maxIptu;
  final bool showOnlyWithPrice;
  final bool acceptProposal;
  final bool hasFinancing;
  final List<String> priceRanges;
  final List<PropertyType> propertyTypes;
  final List<String> cities;
  final List<String> neighborhoods;
  final int? minBedrooms;
  final int? maxBedrooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minParkingSpaces;
  final int? maxParkingSpaces;
  final double? minArea;
  final double? maxArea;
  final bool furnished;
  final bool petFriendly;
  final bool hasSecurity;
  final bool hasSwimmingPool;
  final bool hasGym;
  final List<String> savedFilters;

  const PropertyFilters({
    this.minPrice,
    this.maxPrice,
    this.transactionType,
    this.maxCondominium,
    this.maxIptu,
    this.showOnlyWithPrice = false,
    this.acceptProposal = false,
    this.hasFinancing = false,
    this.priceRanges = const [],
    this.propertyTypes = const [],
    this.cities = const [],
    this.neighborhoods = const [],
    this.minBedrooms,
    this.maxBedrooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minParkingSpaces,
    this.maxParkingSpaces,
    this.minArea,
    this.maxArea,
    this.furnished = false,
    this.petFriendly = false,
    this.hasSecurity = false,
    this.hasSwimmingPool = false,
    this.hasGym = false,
    this.savedFilters = const [],
  });

  PropertyFilters copyWith({
    double? minPrice,
    double? maxPrice,
    TransactionType? transactionType,
    double? maxCondominium,
    double? maxIptu,
    bool? showOnlyWithPrice,
    bool? acceptProposal,
    bool? hasFinancing,
    List<String>? priceRanges,
    List<PropertyType>? propertyTypes,
    List<String>? cities,
    List<String>? neighborhoods,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minParkingSpaces,
    int? maxParkingSpaces,
    double? minArea,
    double? maxArea,
    bool? furnished,
    bool? petFriendly,
    bool? hasSecurity,
    bool? hasSwimmingPool,
    bool? hasGym,
    List<String>? savedFilters,
  }) {
    return PropertyFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      transactionType: transactionType ?? this.transactionType,
      maxCondominium: maxCondominium ?? this.maxCondominium,
      maxIptu: maxIptu ?? this.maxIptu,
      showOnlyWithPrice: showOnlyWithPrice ?? this.showOnlyWithPrice,
      acceptProposal: acceptProposal ?? this.acceptProposal,
      hasFinancing: hasFinancing ?? this.hasFinancing,
      priceRanges: priceRanges ?? this.priceRanges,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minParkingSpaces: minParkingSpaces ?? this.minParkingSpaces,
      maxParkingSpaces: maxParkingSpaces ?? this.maxParkingSpaces,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      furnished: furnished ?? this.furnished,
      petFriendly: petFriendly ?? this.petFriendly,
      hasSecurity: hasSecurity ?? this.hasSecurity,
      hasSwimmingPool: hasSwimmingPool ?? this.hasSwimmingPool,
      hasGym: hasGym ?? this.hasGym,
      savedFilters: savedFilters ?? this.savedFilters,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        transactionType != null ||
        maxCondominium != null ||
        maxIptu != null ||
        showOnlyWithPrice ||
        acceptProposal ||
        hasFinancing ||
        priceRanges.isNotEmpty ||
        propertyTypes.isNotEmpty ||
        cities.isNotEmpty ||
        neighborhoods.isNotEmpty ||
        minBedrooms != null ||
        maxBedrooms != null ||
        minBathrooms != null ||
        maxBathrooms != null ||
        minParkingSpaces != null ||
        maxParkingSpaces != null ||
        minArea != null ||
        maxArea != null ||
        furnished ||
        petFriendly ||
        hasSecurity ||
        hasSwimmingPool ||
        hasGym;
  }

  PropertyFilters clear() {
    return const PropertyFilters();
  }
}

class PriceRange {
  final String label;
  final double? minPrice;
  final double? maxPrice;

  const PriceRange({
    required this.label,
    this.minPrice,
    this.maxPrice,
  });

  static const List<PriceRange> predefinedRanges = [
    PriceRange(label: 'Até R\$ 100.000', maxPrice: 100000),
    PriceRange(label: 'R\$ 100.000 – R\$ 300.000', minPrice: 100000, maxPrice: 300000),
    PriceRange(label: 'R\$ 300.000 – R\$ 500.000', minPrice: 300000, maxPrice: 500000),
    PriceRange(label: 'R\$ 500.000 – R\$ 1.000.000', minPrice: 500000, maxPrice: 1000000),
    PriceRange(label: 'Acima de R\$ 1.000.000', minPrice: 1000000),
  ];
}