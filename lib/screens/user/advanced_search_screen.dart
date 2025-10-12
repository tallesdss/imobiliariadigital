import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../models/search_model.dart';
import '../../services/search_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'voice_search_screen.dart';
import 'image_search_screen.dart';
import 'map_search_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para campos de texto
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minAreaController = TextEditingController();
  final _maxAreaController = TextEditingController();
  
  // Estado da busca
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  final List<PropertyType> _selectedPropertyTypes = [];
  final List<String> _selectedCities = [];
  final List<String> _selectedNeighborhoods = [];
  PropertyTransactionType? _selectedTransactionType;
  int? _minBedrooms;
  int? _maxBedrooms;
  int? _minBathrooms;
  int? _maxBathrooms;
  int? _minParkingSpaces;
  int? _maxParkingSpaces;
  double? _maxCondominium;
  double? _maxIptu;
  bool _acceptProposal = false;
  bool _hasFinancing = false;
  bool _isFeatured = false;
  bool _isLaunch = false;
  bool _furnished = false;
  bool _petFriendly = false;
  bool _hasSecurity = false;
  bool _hasSwimmingPool = false;
  bool _hasGym = false;
  String _sortBy = 'relevance';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    // Carregar histórico de buscas se necessário
  }

  void _performSearch() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Construir query de busca
      final query = SearchQuery(
        text: _searchController.text.isNotEmpty ? _searchController.text : null,
        propertyTypes: _selectedPropertyTypes.isNotEmpty ? _selectedPropertyTypes : null,
        cities: _selectedCities.isNotEmpty ? _selectedCities : null,
        neighborhoods: _selectedNeighborhoods.isNotEmpty ? _selectedNeighborhoods : null,
        minPrice: _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null,
        maxPrice: _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null,
        transactionType: _selectedTransactionType,
        minBedrooms: _minBedrooms,
        maxBedrooms: _maxBedrooms,
        minBathrooms: _minBathrooms,
        maxBathrooms: _maxBathrooms,
        minParkingSpaces: _minParkingSpaces,
        maxParkingSpaces: _maxParkingSpaces,
        minArea: _minAreaController.text.isNotEmpty ? double.tryParse(_minAreaController.text) : null,
        maxArea: _maxAreaController.text.isNotEmpty ? double.tryParse(_maxAreaController.text) : null,
        maxCondominium: _maxCondominium,
        maxIptu: _maxIptu,
        acceptProposal: _acceptProposal,
        hasFinancing: _hasFinancing,
        isFeatured: _isFeatured,
        isLaunch: _isLaunch,
        furnished: _furnished,
        petFriendly: _petFriendly,
        hasSecurity: _hasSecurity,
        hasSwimmingPool: _hasSwimmingPool,
        hasGym: _hasGym,
        sortBy: _sortBy,
        sortAscending: _sortAscending,
      );

      final results = await SearchService.searchProperties(query);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navegar para tela de resultados
        context.push('/user/search-results', extra: {
          'searchQuery': query,
          'results': results,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _clearFilters() {
    if (!mounted) return;
    
    setState(() {
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minAreaController.clear();
      _maxAreaController.clear();
      _selectedPropertyTypes.clear();
      _selectedCities.clear();
      _selectedNeighborhoods.clear();
      _selectedTransactionType = null;
      _minBedrooms = null;
      _maxBedrooms = null;
      _minBathrooms = null;
      _maxBathrooms = null;
      _minParkingSpaces = null;
      _maxParkingSpaces = null;
      _maxCondominium = null;
      _maxIptu = null;
      _acceptProposal = false;
      _hasFinancing = false;
      _isFeatured = false;
      _isLaunch = false;
      _furnished = false;
      _petFriendly = false;
      _hasSecurity = false;
      _hasSwimmingPool = false;
      _hasGym = false;
      _sortBy = 'relevance';
      _sortAscending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Avançada'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Busca'),
            Tab(icon: Icon(Icons.mic), text: 'Voz'),
            Tab(icon: Icon(Icons.camera_alt), text: 'Imagem'),
            Tab(icon: Icon(Icons.map), text: 'Mapa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          const VoiceSearchScreen(),
          const ImageSearchScreen(),
          const MapSearchScreen(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de busca principal
            _buildSearchField(),
            const SizedBox(height: 16),
            
            // Filtros rápidos
            _buildQuickFilters(),
            const SizedBox(height: 24),
            
            // Filtros detalhados
            _buildDetailedFilters(),
            const SizedBox(height: 24),
            
            // Botões de ação
            _buildActionButtons(),
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LoadingWidget(),
            ],
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              CustomErrorWidget(message: _errorMessage!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Busca por Texto',
              style: AppTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Digite palavras-chave (ex: apartamento 2 quartos)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros Rápidos',
              style: AppTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickFilterChip('Apartamento', () {
                  if (!mounted) return;
                  setState(() {
                    if (_selectedPropertyTypes.contains(PropertyType.apartment)) {
                      _selectedPropertyTypes.remove(PropertyType.apartment);
                    } else {
                      _selectedPropertyTypes.add(PropertyType.apartment);
                    }
                  });
                }, _selectedPropertyTypes.contains(PropertyType.apartment)),
                _buildQuickFilterChip('Casa', () {
                  if (!mounted) return;
                  setState(() {
                    if (_selectedPropertyTypes.contains(PropertyType.house)) {
                      _selectedPropertyTypes.remove(PropertyType.house);
                    } else {
                      _selectedPropertyTypes.add(PropertyType.house);
                    }
                  });
                }, _selectedPropertyTypes.contains(PropertyType.house)),
                _buildQuickFilterChip('Até R\$ 300k', () {
                  if (!mounted) return;
                  setState(() {
                    _maxPriceController.text = '300000';
                  });
                }, _maxPriceController.text == '300000'),
                _buildQuickFilterChip('2+ Quartos', () {
                  if (!mounted) return;
                  setState(() {
                    _minBedrooms = 2;
                  });
                }, _minBedrooms == 2),
                _buildQuickFilterChip('Com Garagem', () {
                  if (!mounted) return;
                  setState(() {
                    _minParkingSpaces = 1;
                  });
                }, _minParkingSpaces == 1),
                _buildQuickFilterChip('Para Alugar', () {
                  if (!mounted) return;
                  setState(() {
                    _selectedTransactionType = _selectedTransactionType == PropertyTransactionType.rent 
                        ? null 
                        : PropertyTransactionType.rent;
                  });
                }, _selectedTransactionType == PropertyTransactionType.rent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDetailedFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros Detalhados',
              style: AppTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Tipo de imóvel
            _buildPropertyTypeFilter(),
            const SizedBox(height: 16),
            
            // Preço
            _buildPriceFilter(),
            const SizedBox(height: 16),
            
            // Características
            _buildCharacteristicsFilter(),
            const SizedBox(height: 16),
            
            // Localização
            _buildLocationFilter(),
            const SizedBox(height: 16),
            
            // Filtros especiais
            _buildSpecialFilters(),
            const SizedBox(height: 16),
            
            // Ordenação
            _buildSortFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo de Imóvel', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: PropertyType.values.map((type) {
            final isSelected = _selectedPropertyTypes.contains(type);
            return FilterChip(
              label: Text(_getPropertyTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() {
                  if (selected) {
                    _selectedPropertyTypes.add(type);
                  } else {
                    _selectedPropertyTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Faixa de Preço', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minPriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço Mínimo',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Preço inválido';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxPriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço Máximo',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Preço inválido';
                    }
                    if (_minPriceController.text.isNotEmpty) {
                      final minPrice = double.tryParse(_minPriceController.text);
                      if (minPrice != null && price < minPrice) {
                        return 'Deve ser maior que o preço mínimo';
                      }
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCharacteristicsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Características', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _minBedrooms,
                decoration: const InputDecoration(
                  labelText: 'Quartos (mín)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Qualquer')),
                  ...List.generate(5, (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  )),
                ],
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _minBedrooms = value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _maxBedrooms,
                decoration: const InputDecoration(
                  labelText: 'Quartos (máx)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Qualquer')),
                  ...List.generate(5, (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  )),
                ],
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _maxBedrooms = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _minBathrooms,
                decoration: const InputDecoration(
                  labelText: 'Banheiros (mín)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Qualquer')),
                  ...List.generate(4, (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  )),
                ],
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _minBathrooms = value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _minParkingSpaces,
                decoration: const InputDecoration(
                  labelText: 'Vagas (mín)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Qualquer')),
                  ...List.generate(5, (index) => DropdownMenuItem(
                    value: index,
                    child: Text('$index'),
                  )),
                ],
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _minParkingSpaces = value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localização', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<PropertyTransactionType>(
          initialValue: _selectedTransactionType,
          decoration: const InputDecoration(
            labelText: 'Tipo de Transação',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Qualquer')),
            const DropdownMenuItem(
              value: PropertyTransactionType.sale,
              child: Text('Venda'),
            ),
            const DropdownMenuItem(
              value: PropertyTransactionType.rent,
              child: Text('Aluguel'),
            ),
            const DropdownMenuItem(
              value: PropertyTransactionType.daily,
              child: Text('Temporada'),
            ),
          ],
          onChanged: (value) {
            if (!mounted) return;
            setState(() => _selectedTransactionType = value);
          },
        ),
      ],
    );
  }

  Widget _buildSpecialFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filtros Especiais', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Aceita Proposta'),
              selected: _acceptProposal,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _acceptProposal = selected);
              },
            ),
            FilterChip(
              label: const Text('Tem Financiamento'),
              selected: _hasFinancing,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _hasFinancing = selected);
              },
            ),
            FilterChip(
              label: const Text('Em Destaque'),
              selected: _isFeatured,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _isFeatured = selected);
              },
            ),
            FilterChip(
              label: const Text('Lançamento'),
              selected: _isLaunch,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _isLaunch = selected);
              },
            ),
            FilterChip(
              label: const Text('Mobiliado'),
              selected: _furnished,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _furnished = selected);
              },
            ),
            FilterChip(
              label: const Text('Aceita Pets'),
              selected: _petFriendly,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _petFriendly = selected);
              },
            ),
            FilterChip(
              label: const Text('Segurança 24h'),
              selected: _hasSecurity,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _hasSecurity = selected);
              },
            ),
            FilterChip(
              label: const Text('Piscina'),
              selected: _hasSwimmingPool,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _hasSwimmingPool = selected);
              },
            ),
            FilterChip(
              label: const Text('Academia'),
              selected: _hasGym,
              onSelected: (selected) {
                if (!mounted) return;
                setState(() => _hasGym = selected);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ordenar por', style: AppTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _sortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'relevance', child: Text('Relevância')),
                  DropdownMenuItem(value: 'price', child: Text('Preço')),
                  DropdownMenuItem(value: 'date', child: Text('Data')),
                  DropdownMenuItem(value: 'area', child: Text('Área')),
                ],
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _sortBy = value!);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<bool>(
                initialValue: _sortAscending,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: false, child: Text('Decrescente')),
                  DropdownMenuItem(value: true, child: Text('Crescente')),
                ],
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _sortAscending = value!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            child: const Text('Limpar Filtros'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Buscar'),
          ),
        ),
      ],
    );
  }

  String _getPropertyTypeLabel(PropertyType type) {
    switch (type) {
      case PropertyType.house:
        return 'Casa';
      case PropertyType.apartment:
        return 'Apartamento';
      case PropertyType.commercial:
        return 'Comercial';
      case PropertyType.land:
        return 'Terreno';
    }
  }
}
