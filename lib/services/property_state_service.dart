import 'package:flutter/foundation.dart';
import 'property_service.dart';
import '../models/property_model.dart';
import '../models/filter_model.dart';

class PropertyStateService extends ChangeNotifier {
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  List<Property> _featuredProperties = [];
  List<Property> _launchProperties = [];
  List<String> _cities = [];
  Map<String, int> _stats = {};
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  PropertyType? _selectedType;
  PropertyFilters _filters = const PropertyFilters();
  bool _hasMoreData = true;

  // Getters
  List<Property> get allProperties => _allProperties;
  List<Property> get filteredProperties => _filteredProperties;
  List<Property> get featuredProperties => _featuredProperties;
  List<Property> get launchProperties => _launchProperties;
  List<String> get cities => _cities;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  PropertyType? get selectedType => _selectedType;
  PropertyFilters get filters => _filters;
  bool get hasMoreData => _hasMoreData;

  Future<void> initialize() async {
    _isLoading = true;
    try {
      await Future.wait([
        _loadFeaturedProperties(),
        _loadLaunchProperties(),
        _loadCities(),
        _loadStats(),
      ]);
    } catch (e) {
      _error = 'Erro ao inicializar dados: $e';
    } finally {
      _isLoading = false;
      // Notificar apenas no final da inicialização
      notifyListeners();
    }
  }

  Future<void> loadProperties({bool refresh = false}) async {
    if (refresh) {
      _hasMoreData = true;
      _allProperties.clear();
    }

    if (!_hasMoreData && !refresh) return;

    _setLoadingMore(true);
    _clearError();
    
    try {
      // Carregar todos os imóveis disponíveis (sem limite de página)
      final newProperties = await PropertyService.getAllProperties(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        type: _selectedType,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
      );

      if (refresh) {
        _allProperties = newProperties;
      } else {
        _allProperties.addAll(newProperties);
      }

      _hasMoreData = false; // Todos os imóveis foram carregados

      _applyFilters();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingMore(false);
    }
  }

  Future<void> _loadFeaturedProperties() async {
    try {
      _featuredProperties = await PropertyService.getFeaturedProperties();
    } catch (e) {
      // Ignora erro para propriedades em destaque
    }
  }

  Future<void> _loadLaunchProperties() async {
    try {
      _launchProperties = await PropertyService.getLaunchProperties();
    } catch (e) {
      // Ignora erro para lançamentos
    }
  }

  Future<void> _loadCities() async {
    try {
      _cities = await PropertyService.getCities();
    } catch (e) {
      // Ignora erro para cidades
    }
  }

  Future<void> _loadStats() async {
    try {
      _stats = await PropertyService.getPropertyStats();
    } catch (e) {
      // Ignora erro para estatísticas
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _hasMoreData = true;
    _allProperties.clear();
    loadProperties(refresh: true);
  }

  void setSelectedType(PropertyType? type) {
    _selectedType = type;
    _hasMoreData = true;
    _allProperties.clear();
    loadProperties(refresh: true);
  }

  void setFilters(PropertyFilters filters) {
    _filters = filters;
    _hasMoreData = true;
    _allProperties.clear();
    loadProperties(refresh: true);
  }

  void clearFilters() {
    _filters = const PropertyFilters();
    _selectedType = null;
    _searchQuery = '';
    _hasMoreData = true;
    _allProperties.clear();
    loadProperties(refresh: true);
  }

  void _applyFilters() {
    _filteredProperties = _allProperties.where((property) {
      // Aplicar filtro por tipo de propriedade
      if (_selectedType != null && property.type != _selectedType) {
        return false;
      }
      
      // Aplicar filtros avançados
      return _matchesAdvancedFilters(property);
    }).toList();
    notifyListeners();
  }

  bool _matchesAdvancedFilters(Property property) {
    // Filtro de tipo de transação
    if (_filters.transactionType != null) {
      if (property.transactionType == null) return false;
      
      // Converter TransactionType para PropertyTransactionType
      PropertyTransactionType? propertyTransactionType;
      switch (_filters.transactionType!) {
        case TransactionType.sale:
          propertyTransactionType = PropertyTransactionType.sale;
          break;
        case TransactionType.rent:
          propertyTransactionType = PropertyTransactionType.rent;
          break;
        case TransactionType.daily:
          propertyTransactionType = PropertyTransactionType.daily;
          break;
      }
      
      if (property.transactionType != propertyTransactionType) {
        return false;
      }
    }

    // Filtro de faixas de preço
    if (_filters.priceRanges.isNotEmpty) {
      bool matchesAnyRange = false;
      for (final rangeLabel in _filters.priceRanges) {
        final range = PriceRange.predefinedRanges.firstWhere(
          (r) => r.label == rangeLabel,
          orElse: () => const PriceRange(label: ''),
        );
        
        bool matchesRange = true;
        if (range.minPrice != null && property.price < range.minPrice!) {
          matchesRange = false;
        }
        if (range.maxPrice != null && property.price > range.maxPrice!) {
          matchesRange = false;
        }
        
        if (matchesRange) {
          matchesAnyRange = true;
          break;
        }
      }
      if (!matchesAnyRange) return false;
    }

    // Filtro de condomínio
    if (_filters.maxCondominium != null) {
      final condominium = property.attributes['condominium'] as double? ?? 0;
      if (condominium > _filters.maxCondominium!) {
        return false;
      }
    }

    // Filtro de IPTU
    if (_filters.maxIptu != null) {
      final iptu = property.attributes['iptu'] as double? ?? 0;
      if (iptu > _filters.maxIptu!) {
        return false;
      }
    }

    // Filtro de imóveis com preço informado
    if (_filters.showOnlyWithPrice && property.price <= 0) {
      return false;
    }

    // Filtro de aceita proposta
    if (_filters.acceptProposal) {
      final acceptsProposal = property.attributes['acceptsProposal'] as bool? ?? false;
      if (!acceptsProposal) {
        return false;
      }
    }

    // Filtro de financiamento
    if (_filters.hasFinancing) {
      final hasFinancing = property.attributes['hasFinancing'] as bool? ?? false;
      if (!hasFinancing) {
        return false;
      }
    }

    return true;
  }

  Future<void> refresh() async {
    await loadProperties(refresh: true);
  }

  Future<void> loadMore() async {
    if (!_isLoadingMore && _hasMoreData) {
      await loadProperties();
    }
  }

  void _setLoadingMore(bool loading) {
    if (_isLoadingMore != loading) {
      _isLoadingMore = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
