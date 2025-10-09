import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../models/filter_model.dart';
import '../../widgets/cards/property_card.dart';
import '../../widgets/common/filter_sidebar.dart';
import 'property_detail_screen.dart';
import 'favorites_screen.dart';
import 'property_comparison_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  final Set<String> _favoritePropertyIds = {};
  final Set<String> _comparePropertyIds = {};
  String _searchQuery = '';
  PropertyType? _selectedType;
  bool _isLoading = true;
  bool _showCarousels = true;
  bool _showOnlyLaunches = false;
  bool _showFilters = false;
  PropertyFilters _filters = const PropertyFilters();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    // Carregar dados
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final activeProps = MockDataService.activeProperties;
        final favorites = MockDataService.getFavoriteProperties('user1');
        
        setState(() {
          _allProperties = activeProps;
          _filteredProperties = activeProps;
          _favoritePropertyIds.clear();
          _favoritePropertyIds.addAll(favorites.map((p) => p.id));
          _isLoading = false;
        });
      }
    });
  }

  void _filterProperties() {
    setState(() {
      _filteredProperties = _allProperties.where((property) {
        final matchesSearch = _searchQuery.isEmpty ||
            property.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            property.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            property.address.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesType = _selectedType == null || property.type == _selectedType;
        final matchesLaunch = !_showOnlyLaunches || property.isLaunch;

        // Aplicar filtros da barra lateral
        final matchesFilters = _applyAdvancedFilters(property);

        return matchesSearch && matchesType && matchesLaunch && matchesFilters;
      }).toList();

      // Mostrar carrosséis apenas quando não há busca ou filtro ativo
      _showCarousels = _searchQuery.isEmpty && 
          _selectedType == null && 
          !_showOnlyLaunches && 
          !_filters.hasActiveFilters;
    });
  }

  bool _applyAdvancedFilters(Property property) {
    // Filtro de preço mínimo
    if (_filters.minPrice != null && property.price < _filters.minPrice!) {
      return false;
    }

    // Filtro de preço máximo
    if (_filters.maxPrice != null && property.price > _filters.maxPrice!) {
      return false;
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

    // Filtro de condomínio (simulado através dos atributos)
    if (_filters.maxCondominium != null) {
      final condominium = property.attributes['condominium'] as double? ?? 0;
      if (condominium > _filters.maxCondominium!) {
        return false;
      }
    }

    // Filtro de IPTU (simulado através dos atributos)
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

    // Filtro de aceita proposta (simulado através dos atributos)
    if (_filters.acceptProposal) {
      final acceptsProposal = property.attributes['acceptsProposal'] as bool? ?? false;
      if (!acceptsProposal) {
        return false;
      }
    }

    // Filtro de financiamento (simulado através dos atributos)
    if (_filters.hasFinancing) {
      final hasFinancing = property.attributes['hasFinancing'] as bool? ?? false;
      if (!hasFinancing) {
        return false;
      }
    }

    return true;
  }

  void _toggleFavorite(String propertyId) {
    setState(() {
      if (_favoritePropertyIds.contains(propertyId)) {
        _favoritePropertyIds.remove(propertyId);
        MockDataService.removeFavorite('user1', propertyId);
      } else {
        _favoritePropertyIds.add(propertyId);
        MockDataService.addFavorite('user1', propertyId);
      }
    });
  }

  void _toggleCompare(String propertyId) {
    setState(() {
      if (_comparePropertyIds.contains(propertyId)) {
        _comparePropertyIds.remove(propertyId);
      } else if (_comparePropertyIds.length < 3) {
        _comparePropertyIds.add(propertyId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você pode comparar no máximo 3 imóveis'),
          ),
        );
      }
    });
  }

  Widget _buildMainContent() {
    if (_showCarousels) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildCarousels(),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todos os Imóveis',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            _buildPropertiesGrid(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      );
    } else {
      return _buildPropertiesGrid();
    }
  }

  Widget _buildCarousels() {
    // Separar propriedades por categoria
    final launches = _allProperties.where((p) => p.isLaunch).toList();
    final houses = _allProperties.where((p) => p.type == PropertyType.house).toList();
    final apartments = _allProperties.where((p) => p.type == PropertyType.apartment).toList();

    return Column(
      children: [
        if (launches.isNotEmpty) ...[
          _buildCarousel('🚀 Lançamentos', launches, () {
            setState(() {
              _showOnlyLaunches = true;
              _selectedType = null;
              _filterProperties();
            });
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (houses.isNotEmpty) ...[
          _buildCarousel('🏠 Casas', houses, () {
            setState(() {
              _selectedType = PropertyType.house;
              _showOnlyLaunches = false;
              _filterProperties();
            });
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (apartments.isNotEmpty) ...[
          _buildCarousel('🏢 Apartamentos', apartments, () {
            setState(() {
              _selectedType = PropertyType.apartment;
              _showOnlyLaunches = false;
              _filterProperties();
            });
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }

  Widget _buildCarousel(String title, List<Property> properties, VoidCallback onSeeAll) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 20,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'Ver todos',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: isTablet ? 360 : 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : AppSpacing.lg,
            ),
            itemCount: properties.length > (isTablet ? 6 : 5) ? (isTablet ? 6 : 5) : properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return Container(
                width: isTablet ? 300 : 280,
                margin: EdgeInsets.only(
                  right: index == properties.length - 1 ? 0 : AppSpacing.md,
                ),
                child: GestureDetector(
                  onTap: () => _navigateToPropertyDetail(property.id),
                  child: PropertyCard(
                    property: property,
                    isFavorite: _favoritePropertyIds.contains(property.id),
                    onFavoriteToggle: () => _toggleFavorite(property.id),
                    onCompare: () {},
                    isCompact: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToPropertyDetail(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(propertyId: propertyId),
      ),
    );
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text('Meu Perfil'),
              onTap: () {
                Navigator.pop(context);
                // Navegar para tela de perfil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tela de perfil em desenvolvimento'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: AppColors.error),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.accent),
              title: const Text('Alertas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/alerts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.primary),
              title: const Text('Mensagens'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user-chat');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: AppColors.textSecondary,
              ),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configurações em desenvolvimento'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToComparison() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PropertyComparisonScreen(propertyIds: _comparePropertyIds.toList()),
      ),
    );
  }

  void _onFiltersChanged(PropertyFilters filters) {
    setState(() {
      _filters = filters;
    });
    _filterProperties();
  }

  void _onClearFilters() {
    setState(() {
      _filters = const PropertyFilters();
    });
    _filterProperties();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _showMobileFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Filtros',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_filters.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _onClearFilters();
                      },
                      child: Text(
                        'Limpar',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            // Filtros
            Expanded(
              child: FilterSidebar(
                filters: _filters,
                onFiltersChanged: (filters) {
                  setState(() {
                    _filters = filters;
                  });
                  _filterProperties();
                },
                onClearFilters: () {
                  Navigator.pop(context);
                  _onClearFilters();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Barra lateral de filtros
          if (_showFilters && isTablet)
            FilterSidebar(
              filters: _filters,
              onFiltersChanged: _onFiltersChanged,
              onClearFilters: _onClearFilters,
            ),
          
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                _buildSearchAndFilters(),
                _buildCompareBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.home_work, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            'SC IMÓVEIS',
            style: AppTypography.h6.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      actions: [
        // Botão de filtros (apenas para tablets)
        if (MediaQuery.of(context).size.width > 600)
          IconButton(
            onPressed: _toggleFilters,
            icon: Stack(
              children: [
                Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: _showFilters ? AppColors.accent : AppColors.textOnPrimary,
                ),
                if (_filters.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
          ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          },
          icon: Stack(
            children: [
              const Icon(Icons.favorite_outline),
              if (_favoritePropertyIds.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_favoritePropertyIds.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: _showUserMenu,
          icon: const Icon(Icons.account_circle),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      color: Colors.white,
      child: Column(
        children: [
          // Barra de pesquisa com botão de filtros
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterProperties();
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar imóvel...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                              _filterProperties();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                ),
              ),
              // Botão de filtros para mobile
              if (!isTablet) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _filters.hasActiveFilters 
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    border: Border.all(
                      color: _filters.hasActiveFilters 
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: _showMobileFilters,
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: _filters.hasActiveFilters 
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        if (_filters.hasActiveFilters)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Filtros',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Filtros de tipo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', null),
                const SizedBox(width: 8),
                _buildFilterChip('Casas', PropertyType.house),
                const SizedBox(width: 8),
                _buildFilterChip('Apartamentos', PropertyType.apartment),
                const SizedBox(width: 8),
                _buildFilterChip('Comercial', PropertyType.commercial),
                const SizedBox(width: 8),
                _buildFilterChip('Terrenos', PropertyType.land),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PropertyType? type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
        _filterProperties();
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildCompareBar() {
    if (_comparePropertyIds.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.accent.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_comparePropertyIds.length} imóveis selecionados para comparar',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accentDark,
              ),
            ),
          ),
          TextButton(
            onPressed: _comparePropertyIds.length >= 2
                ? _navigateToComparison
                : null,
            child: Text(
              'Comparar',
              style: AppTypography.labelMedium.copyWith(
                color: _comparePropertyIds.length >= 2
                    ? AppColors.accentDark
                    : AppColors.textHint,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _comparePropertyIds.clear();
              });
            },
            child: Text(
              'Limpar',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    
    if (_filteredProperties.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off, 
                size: isTablet ? 80 : 64, 
                color: AppColors.textHint,
              ),
              SizedBox(height: isTablet ? 24 : AppSpacing.md),
              Text(
                'Nenhum imóvel encontrado',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 20 : 18,
                ),
              ),
              SizedBox(height: isTablet ? 12 : AppSpacing.sm),
              Text(
                'Tente ajustar os filtros de busca',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isTablet && !_showCarousels) {
      // Layout em grade para tablets quando não há carrosséis
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: _filteredProperties.length,
        itemBuilder: (context, index) {
          final property = _filteredProperties[index];
          return GestureDetector(
            onTap: () => _navigateToPropertyDetail(property.id),
            child: PropertyCard(
              property: property,
              isFavorite: _favoritePropertyIds.contains(property.id),
              onFavoriteToggle: () => _toggleFavorite(property.id),
              onCompare: () => _toggleCompare(property.id),
            ),
          );
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: _filteredProperties.length,
      separatorBuilder: (context, index) => SizedBox(
        height: isTablet ? 20 : AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final property = _filteredProperties[index];
        return GestureDetector(
          onTap: () => _navigateToPropertyDetail(property.id),
          child: PropertyCard(
            property: property,
            isFavorite: _favoritePropertyIds.contains(property.id),
            onFavoriteToggle: () => _toggleFavorite(property.id),
            onCompare: () => _toggleCompare(property.id),
          ),
        );
      },
    );
  }
}

