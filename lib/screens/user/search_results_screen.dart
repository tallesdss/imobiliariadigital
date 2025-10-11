import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/search_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/cards/property_card.dart';
import 'property_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final SearchQuery searchQuery;
  final List<Property> results;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    required this.results,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Property> _filteredResults = [];
  String _sortBy = 'relevance';
  bool _sortAscending = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _filteredResults = List.from(widget.results);
    _applySorting();
  }

  void _applySorting() {
    _filteredResults.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'area':
          final aArea = a.attributes['area'] as double? ?? 0.0;
          final bArea = b.attributes['area'] as double? ?? 0.0;
          comparison = aArea.compareTo(bArea);
          break;
        case 'relevance':
        default:
          // Ordenar por relevância (imóveis em destaque primeiro)
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {});
  }

  void _onSortChanged(String sortBy, bool ascending) {
    setState(() {
      _sortBy = sortBy;
      _sortAscending = ascending;
    });
    _applySorting();
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _navigateToProperty(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_filteredResults.length} resultados encontrados'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _isGridView ? 'Lista' : 'Grade',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              if (value == 'asc' || value == 'desc') {
                _onSortChanged(_sortBy, value == 'asc');
              } else {
                _onSortChanged(value, _sortAscending);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'relevance',
                child: Text('Relevância'),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Text('Preço'),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Text('Data'),
              ),
              const PopupMenuItem(
                value: 'area',
                child: Text('Área'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'asc',
                child: Row(
                  children: [
                    Icon(_sortAscending ? Icons.check : null),
                    const SizedBox(width: 8),
                    const Text('Crescente'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'desc',
                child: Row(
                  children: [
                    Icon(!_sortAscending ? Icons.check : null),
                    const SizedBox(width: 8),
                    const Text('Decrescente'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_filteredResults.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildSearchSummary(),
        Expanded(
          child: _isGridView ? _buildGridView() : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildSearchSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados da busca',
            style: AppTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _buildSearchDescription(),
            style: AppTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _buildSearchDescription() {
    final parts = <String>[];
    
    if (widget.searchQuery.text != null && widget.searchQuery.text!.isNotEmpty) {
      parts.add('"${widget.searchQuery.text}"');
    }
    
    if (widget.searchQuery.propertyTypes != null && widget.searchQuery.propertyTypes!.isNotEmpty) {
      final types = widget.searchQuery.propertyTypes!.map((type) {
        switch (type) {
          case PropertyType.house:
            return 'casa';
          case PropertyType.apartment:
            return 'apartamento';
          case PropertyType.commercial:
            return 'comercial';
          case PropertyType.land:
            return 'terreno';
        }
      }).join(', ');
      parts.add('tipo: $types');
    }
    
    if (widget.searchQuery.cities != null && widget.searchQuery.cities!.isNotEmpty) {
      parts.add('em ${widget.searchQuery.cities!.join(', ')}');
    }
    
    if (widget.searchQuery.minPrice != null || widget.searchQuery.maxPrice != null) {
      final min = widget.searchQuery.minPrice != null 
          ? 'R\$ ${widget.searchQuery.minPrice!.toStringAsFixed(0)}'
          : 'R\$ 0';
      final max = widget.searchQuery.maxPrice != null 
          ? 'R\$ ${widget.searchQuery.maxPrice!.toStringAsFixed(0)}'
          : 'sem limite';
      parts.add('preço: $min - $max');
    }
    
    if (parts.isEmpty) {
      return 'Busca geral';
    }
    
    return parts.join(' • ');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum imóvel encontrado',
              style: AppTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros de busca para encontrar mais resultados.',
              style: AppTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajustar Filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final property = _filteredResults[index];
        return PropertyCard(
          property: property,
          onTap: () => _navigateToProperty(property),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final property = _filteredResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _navigateToProperty(property),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem do imóvel
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 120,
                      height: 90,
                      color: Colors.grey[200],
                      child: property.photos.isNotEmpty
                          ? Image.network(
                              property.photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.home,
                                  size: 40,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.home,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Informações do imóvel
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: AppTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          property.address,
                          style: AppTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.bed,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${property.attributes['bedrooms'] ?? 0}',
                              style: AppTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.bathtub,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${property.attributes['bathrooms'] ?? 0}',
                              style: AppTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.square_foot,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${property.attributes['area'] ?? 0}m²',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              property.formattedPrice,
                              style: AppTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (property.isFeatured)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'DESTAQUE',
                                  style: AppTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
