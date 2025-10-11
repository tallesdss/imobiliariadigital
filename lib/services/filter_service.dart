import '../models/property_model.dart';
import '../models/filter_model.dart';

class FilterService {
  // Aplicar filtros para usuários
  static List<Property> applyUserFilters(
    List<Property> properties,
    UserPropertyFilters filters,
  ) {
    return properties.where((property) {
      // Filtro de preço
      if (filters.minPrice != null && property.price < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && property.price > filters.maxPrice!) {
        return false;
      }

      // Filtro de tipo de transação
      if (filters.transactionType != null && 
          property.transactionType?.name != filters.transactionType!.name) {
        return false;
      }

      // Filtro de tipo de imóvel
      if (filters.propertyTypes.isNotEmpty && 
          !filters.propertyTypes.contains(property.type)) {
        return false;
      }

      // Filtro de cidade
      if (filters.cities.isNotEmpty && 
          !filters.cities.contains(property.city)) {
        return false;
      }

      // Filtro de bairro (assumindo que o bairro está no endereço)
      if (filters.neighborhoods.isNotEmpty) {
        final hasMatchingNeighborhood = filters.neighborhoods.any(
          (neighborhood) => property.address.toLowerCase().contains(neighborhood.toLowerCase())
        );
        if (!hasMatchingNeighborhood) {
          return false;
        }
      }

      // Filtros de características
      final attributes = property.attributes;
      
      // Quartos
      if (filters.minBedrooms != null) {
        final bedrooms = attributes['bedrooms'] as int? ?? 0;
        if (bedrooms < filters.minBedrooms!) {
          return false;
        }
      }
      if (filters.maxBedrooms != null) {
        final bedrooms = attributes['bedrooms'] as int? ?? 0;
        if (bedrooms > filters.maxBedrooms!) {
          return false;
        }
      }

      // Banheiros
      if (filters.minBathrooms != null) {
        final bathrooms = attributes['bathrooms'] as int? ?? 0;
        if (bathrooms < filters.minBathrooms!) {
          return false;
        }
      }
      if (filters.maxBathrooms != null) {
        final bathrooms = attributes['bathrooms'] as int? ?? 0;
        if (bathrooms > filters.maxBathrooms!) {
          return false;
        }
      }

      // Vagas de garagem
      if (filters.minParkingSpaces != null) {
        final parking = attributes['parking_spaces'] as int? ?? 0;
        if (parking < filters.minParkingSpaces!) {
          return false;
        }
      }
      if (filters.maxParkingSpaces != null) {
        final parking = attributes['parking_spaces'] as int? ?? 0;
        if (parking > filters.maxParkingSpaces!) {
          return false;
        }
      }

      // Área
      if (filters.minArea != null) {
        final area = attributes['area'] as double? ?? 0.0;
        if (area < filters.minArea!) {
          return false;
        }
      }
      if (filters.maxArea != null) {
        final area = attributes['area'] as double? ?? 0.0;
        if (area > filters.maxArea!) {
          return false;
        }
      }

      // Filtros de condomínio e IPTU
      if (filters.maxCondominium != null) {
        final condominium = attributes['condominium'] as double? ?? 0.0;
        if (condominium > filters.maxCondominium!) {
          return false;
        }
      }
      if (filters.maxIptu != null) {
        final iptu = attributes['iptu'] as double? ?? 0.0;
        if (iptu > filters.maxIptu!) {
          return false;
        }
      }

      // Filtros especiais
      if (filters.showOnlyWithPrice && property.price <= 0) {
        return false;
      }

      if (filters.acceptProposal) {
        final acceptsProposal = attributes['accepts_proposal'] as bool? ?? false;
        if (!acceptsProposal) {
          return false;
        }
      }

      if (filters.hasFinancing) {
        final hasFinancing = attributes['has_financing'] as bool? ?? false;
        if (!hasFinancing) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Aplicar filtros para corretores
  static List<Property> applyRealtorFilters(
    List<Property> properties,
    RealtorPropertyFilters filters,
  ) {
    var filteredProperties = properties.where((property) {
      // Filtro de status
      if (filters.statuses.isNotEmpty && 
          !filters.statuses.contains(property.status)) {
        return false;
      }

      // Filtro de data de criação
      if (filters.startDate != null && 
          property.createdAt.isBefore(filters.startDate!)) {
        return false;
      }
      if (filters.endDate != null && 
          property.createdAt.isAfter(filters.endDate!)) {
        return false;
      }

      // Filtro de data de atualização
      if (filters.lastUpdateStart != null && 
          property.updatedAt.isBefore(filters.lastUpdateStart!)) {
        return false;
      }
      if (filters.lastUpdateEnd != null && 
          property.updatedAt.isAfter(filters.lastUpdateEnd!)) {
        return false;
      }

      // Filtros básicos (reutilizar lógica do usuário)
      final userFilters = UserPropertyFilters(
        propertyTypes: filters.propertyTypes,
        cities: filters.cities,
        neighborhoods: filters.neighborhoods,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        transactionType: filters.transactionType,
      );
      
      if (!_matchesUserFilters(property, userFilters)) {
        return false;
      }

      // Filtros específicos do corretor
      if (filters.showOnlyFeatured && !property.isFeatured) {
        return false;
      }

      if (filters.showOnlyLaunches && !property.isLaunch) {
        return false;
      }

      // Filtros de performance (simulados)
      if (filters.minViews != null) {
        final views = property.attributes['views'] as int? ?? 0;
        if (views < filters.minViews!) {
          return false;
        }
      }

      if (filters.minLeads != null) {
        final leads = property.attributes['leads'] as int? ?? 0;
        if (leads < filters.minLeads!) {
          return false;
        }
      }

      return true;
    }).toList();

    // Aplicar ordenação
    return _sortProperties(filteredProperties, filters.sortBy, filters.sortAscending);
  }

  // Aplicar filtros para administradores
  static List<Property> applyAdminFilters(
    List<Property> properties,
    AdminPropertyFilters filters,
  ) {
    var filteredProperties = properties.where((property) {
      // Filtro por corretor
      if (filters.realtorIds.isNotEmpty && 
          !filters.realtorIds.contains(property.realtorId)) {
        return false;
      }

      // Filtro de status
      if (filters.statuses.isNotEmpty && 
          !filters.statuses.contains(property.status)) {
        return false;
      }

      // Filtro de data de criação
      if (filters.startDate != null && 
          property.createdAt.isBefore(filters.startDate!)) {
        return false;
      }
      if (filters.endDate != null && 
          property.createdAt.isAfter(filters.endDate!)) {
        return false;
      }

      // Filtros básicos (reutilizar lógica do usuário)
      final userFilters = UserPropertyFilters(
        propertyTypes: filters.propertyTypes,
        cities: filters.cities,
        neighborhoods: filters.neighborhoods,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        transactionType: filters.transactionType,
      );
      
      if (!_matchesUserFilters(property, userFilters)) {
        return false;
      }

      // Filtros específicos do administrador
      if (filters.showOnlyFeatured && !property.isFeatured) {
        return false;
      }

      if (filters.showOnlyLaunches && !property.isLaunch) {
        return false;
      }

      // Filtros de performance
      if (filters.minViews != null) {
        final views = property.attributes['views'] as int? ?? 0;
        if (views < filters.minViews!) {
          return false;
        }
      }

      if (filters.minLeads != null) {
        final leads = property.attributes['leads'] as int? ?? 0;
        if (leads < filters.minLeads!) {
          return false;
        }
      }

      // Filtro de performance geral
      if (filters.performanceFilter != null) {
        final views = property.attributes['views'] as int? ?? 0;
        final leads = property.attributes['leads'] as int? ?? 0;
        final performance = (views * 0.3 + leads * 0.7).toInt();
        
        switch (filters.performanceFilter) {
          case 'high':
            if (performance < 50) return false;
            break;
          case 'medium':
            if (performance < 20 || performance >= 50) return false;
            break;
          case 'low':
            if (performance >= 20) return false;
            break;
        }
      }

      return true;
    }).toList();

    // Aplicar ordenação
    return _sortProperties(filteredProperties, filters.sortBy, filters.sortAscending);
  }

  // Método auxiliar para verificar filtros de usuário
  static bool _matchesUserFilters(Property property, UserPropertyFilters filters) {
    // Filtro de preço
    if (filters.minPrice != null && property.price < filters.minPrice!) {
      return false;
    }
    if (filters.maxPrice != null && property.price > filters.maxPrice!) {
      return false;
    }

    // Filtro de tipo de transação
    if (filters.transactionType != null && 
        property.transactionType?.name != filters.transactionType!.name) {
      return false;
    }

    // Filtro de tipo de imóvel
    if (filters.propertyTypes.isNotEmpty && 
        !filters.propertyTypes.contains(property.type)) {
      return false;
    }

    // Filtro de cidade
    if (filters.cities.isNotEmpty && 
        !filters.cities.contains(property.city)) {
      return false;
    }

    // Filtro de bairro
    if (filters.neighborhoods.isNotEmpty) {
      final hasMatchingNeighborhood = filters.neighborhoods.any(
        (neighborhood) => property.address.toLowerCase().contains(neighborhood.toLowerCase())
      );
      if (!hasMatchingNeighborhood) {
        return false;
      }
    }

    return true;
  }

  // Método auxiliar para ordenação
  static List<Property> _sortProperties(
    List<Property> properties,
    String sortBy,
    bool ascending,
  ) {
    final sortedProperties = List<Property>.from(properties);
    
    sortedProperties.sort((a, b) {
      int comparison = 0;
      
      switch (sortBy) {
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'status':
          comparison = a.status.name.compareTo(b.status.name);
          break;
        case 'realtor':
          comparison = a.realtorName.compareTo(b.realtorName);
          break;
        case 'interest':
          final aInterest = (a.attributes['views'] as int? ?? 0) + 
                           (a.attributes['leads'] as int? ?? 0);
          final bInterest = (b.attributes['views'] as int? ?? 0) + 
                           (b.attributes['leads'] as int? ?? 0);
          comparison = aInterest.compareTo(bInterest);
          break;
        case 'performance':
          final aPerformance = (a.attributes['views'] as int? ?? 0) * 0.3 + 
                              (a.attributes['leads'] as int? ?? 0) * 0.7;
          final bPerformance = (b.attributes['views'] as int? ?? 0) * 0.3 + 
                              (b.attributes['leads'] as int? ?? 0) * 0.7;
          comparison = aPerformance.compareTo(bPerformance);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      
      return ascending ? comparison : -comparison;
    });
    
    return sortedProperties;
  }

  // Obter opções de filtros rápidos para usuários
  static List<QuickFilter> getUserQuickFilters() {
    return [
      QuickFilter(
        name: 'Até R\$ 200.000',
        filters: UserPropertyFilters(maxPrice: 200000),
      ),
      QuickFilter(
        name: 'R\$ 200.000 - R\$ 500.000',
        filters: UserPropertyFilters(minPrice: 200000, maxPrice: 500000),
      ),
      QuickFilter(
        name: 'Apartamentos',
        filters: UserPropertyFilters(propertyTypes: [PropertyType.apartment]),
      ),
      QuickFilter(
        name: 'Casas',
        filters: UserPropertyFilters(propertyTypes: [PropertyType.house]),
      ),
      QuickFilter(
        name: 'Para alugar',
        filters: UserPropertyFilters(transactionType: TransactionType.rent),
      ),
      QuickFilter(
        name: 'Com garagem',
        filters: UserPropertyFilters(minParkingSpaces: 1),
      ),
    ];
  }

  // Obter opções de filtros rápidos para corretores
  static List<QuickFilter> getRealtorQuickFilters() {
    return [
      QuickFilter(
        name: 'Ativos',
        filters: RealtorPropertyFilters(statuses: [PropertyStatus.active]),
      ),
      QuickFilter(
        name: 'Vendidos',
        filters: RealtorPropertyFilters(statuses: [PropertyStatus.sold]),
      ),
      QuickFilter(
        name: 'Em destaque',
        filters: RealtorPropertyFilters(showOnlyFeatured: true),
      ),
      QuickFilter(
        name: 'Lançamentos',
        filters: RealtorPropertyFilters(showOnlyLaunches: true),
      ),
      QuickFilter(
        name: 'Últimos 30 dias',
        filters: RealtorPropertyFilters(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ),
      QuickFilter(
        name: 'Alta performance',
        filters: RealtorPropertyFilters(minViews: 50, minLeads: 10),
      ),
    ];
  }

  // Obter opções de filtros rápidos para administradores
  static List<QuickFilter> getAdminQuickFilters() {
    return [
      QuickFilter(
        name: 'Todos ativos',
        filters: AdminPropertyFilters(statuses: [PropertyStatus.active]),
      ),
      QuickFilter(
        name: 'Vendidos este mês',
        filters: AdminPropertyFilters(
          statuses: [PropertyStatus.sold],
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        ),
      ),
      QuickFilter(
        name: 'Em destaque',
        filters: AdminPropertyFilters(showOnlyFeatured: true),
      ),
      QuickFilter(
        name: 'Lançamentos',
        filters: AdminPropertyFilters(showOnlyLaunches: true),
      ),
      QuickFilter(
        name: 'Alta performance',
        filters: AdminPropertyFilters(performanceFilter: 'high'),
      ),
      QuickFilter(
        name: 'Últimos 7 dias',
        filters: AdminPropertyFilters(
          startDate: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ),
    ];
  }
}

// Classe para filtros rápidos
class QuickFilter {
  final String name;
  final dynamic filters; // Pode ser UserPropertyFilters, RealtorPropertyFilters ou AdminPropertyFilters

  const QuickFilter({
    required this.name,
    required this.filters,
  });
}
