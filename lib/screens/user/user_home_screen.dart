import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../widgets/cards/property_card.dart';
import 'property_detail_screen.dart';
import 'favorites_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  final Set<String> _favoritePropertyIds = {};
  final Set<String> _comparePropertyIds = {};
  String _searchQuery = '';
  PropertyType? _selectedType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadFavorites();
  }

  void _loadProperties() {
    setState(() {
      _isLoading = true;
    });

    // Simular carregamento
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _properties = MockDataService.activeProperties;
        _filteredProperties = _properties;
        _isLoading = false;
      });
    });
  }

  void _loadFavorites() {
    // Simular usuário logado
    final favorites = MockDataService.getFavoriteProperties('user1');
    setState(() {
      _favoritePropertyIds.clear();
      _favoritePropertyIds.addAll(favorites.map((p) => p.id));
    });
  }

  void _filterProperties() {
    setState(() {
      _filteredProperties = _properties.where((property) {
        final matchesSearch = _searchQuery.isEmpty ||
            property.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            property.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            property.address.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesType = _selectedType == null || property.type == _selectedType;

        return matchesSearch && matchesType;
      }).toList();
    });
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

  void _navigateToPropertyDetail(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(propertyId: propertyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildCompareBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPropertiesList(),
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
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoritesScreen(),
              ),
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
          onPressed: () {
            // TODO: Implementar menu do usuário
          },
          icon: const Icon(Icons.account_circle),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Barra de pesquisa
          TextField(
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
            ),
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
                ? () {
                    // TODO: Implementar tela de comparação
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comparação em desenvolvimento'),
                      ),
                    );
                  }
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

  Widget _buildPropertiesList() {
    if (_filteredProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum imóvel encontrado',
              style: AppTypography.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros de busca',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
}
