import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/property_model.dart';
import '../../models/search_model.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'property_detail_screen.dart';
import 'search_results_screen.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  bool _isLoading = false;
  bool _isLocationLoading = false;
  String? _errorMessage;
  LocationData? _currentLocation;
  List<PropertyWithDistance> _nearbyProperties = [];
  double _searchRadius = 5.0; // km
  bool _showPOIs = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLocationLoading = true;
      _errorMessage = null;
    });

    try {
      // Verificar se o serviço está habilitado
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado. Ative nas configurações do dispositivo.');
      }

      // Verificar permissões
      LocationPermission permission = await LocationService.checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await LocationService.requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada. É necessário para usar a busca por mapa.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente. Ative nas configurações do app.');
      }

      // Obter localização atual
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _currentLocation = location;
        });
        await _searchNearbyProperties();
      } else {
        throw Exception('Não foi possível obter a localização atual.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _searchNearbyProperties() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Buscar propriedades próximas
      final properties = await LocationService.getNearbyProperties(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _searchRadius,
      );

      setState(() {
        _nearbyProperties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onRadiusChanged(double radius) {
    setState(() {
      _searchRadius = radius;
    });
    _searchNearbyProperties();
  }

  void _onPOIsToggled(bool show) {
    setState(() {
      _showPOIs = show;
    });
    _searchNearbyProperties();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<PropertyWithDistance> _getFilteredProperties() {
    if (_selectedFilter == 'all') {
      return _nearbyProperties;
    }

    return _nearbyProperties.where((item) {
      switch (_selectedFilter) {
        case 'houses':
          return item.property.type == PropertyType.house;
        case 'apartments':
          return item.property.type == PropertyType.apartment;
        case 'commercial':
          return item.property.type == PropertyType.commercial;
        case 'land':
          return item.property.type == PropertyType.land;
        case 'sale':
          return item.property.transactionType == PropertyTransactionType.sale;
        case 'rent':
          return item.property.transactionType == PropertyTransactionType.rent;
        default:
          return true;
      }
    }).toList();
  }

  void _navigateToProperty(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: property),
      ),
    );
  }

  void _viewAllResults() {
    final properties = _getFilteredProperties().map((item) => item.property).toList();
    
    final searchQuery = SearchQuery(
      latitude: _currentLocation?.latitude,
      longitude: _currentLocation?.longitude,
      radiusKm: _searchRadius,
      sortBy: 'distance',
      sortAscending: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          searchQuery: searchQuery,
          results: properties,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_isLocationLoading) ...[
              const Expanded(child: LoadingWidget()),
            ] else if (_errorMessage != null) ...[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        CustomErrorWidget(message: _errorMessage!),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              _buildMapControls(),
              Expanded(
                child: _buildMapView(),
              ),
              _buildResultsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor,
      child: Row(
        children: [
          Icon(
            Icons.map,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Busca por Mapa',
                  style: AppTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentLocation != null)
                  Text(
                    _currentLocation!.address,
                    style: AppTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _requestLocationPermission,
            icon: const Icon(Icons.my_location, color: Colors.white),
            tooltip: 'Atualizar localização',
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Controle de raio
          Row(
            children: [
              Text(
                'Raio de busca: ${_searchRadius.toInt()} km',
                style: AppTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                '1 km',
                style: AppTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: _searchRadius,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  onChanged: _onRadiusChanged,
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              Text(
                '20 km',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          
          // Filtros
          Row(
            children: [
              Text(
                'Filtros:',
                style: AppTheme.titleSmall,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Todos'),
                      _buildFilterChip('houses', 'Casas'),
                      _buildFilterChip('apartments', 'Apartamentos'),
                      _buildFilterChip('commercial', 'Comercial'),
                      _buildFilterChip('sale', 'Venda'),
                      _buildFilterChip('rent', 'Aluguel'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Toggle POIs
          Row(
            children: [
              Text(
                'Pontos de interesse:',
                style: AppTheme.titleSmall,
              ),
              const Spacer(),
              Switch(
                value: _showPOIs,
                onChanged: _onPOIsToggled,
                activeThumbColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _onFilterChanged(value),
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Mapa simulado (em implementação real, seria um widget de mapa)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.green[50],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mapa Interativo',
                      style: AppTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Em implementação real, aqui seria exibido um mapa com marcadores dos imóveis e pontos de interesse.',
                      style: AppTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Indicador de carregamento
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: LoadingWidget(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final filteredProperties = _getFilteredProperties();
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Imóveis Próximos (${filteredProperties.length})',
                style: AppTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (filteredProperties.isNotEmpty)
                TextButton(
                  onPressed: _viewAllResults,
                  child: const Text('Ver Todos'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredProperties.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum imóvel encontrado neste raio',
                      style: AppTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredProperties.length,
                    itemBuilder: (context, index) {
                      final item = filteredProperties[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          child: InkWell(
                            onTap: () => _navigateToProperty(item.property),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagem do imóvel
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: item.property.photos.isNotEmpty
                                            ? Image.network(
                                                item.property.photos.first,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.home,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  );
                                                },
                                              )
                                            : const Icon(
                                                Icons.home,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Informações do imóvel
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.property.title,
                                          style: AppTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.property.formattedPrice,
                                          style: AppTheme.bodySmall?.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${item.distance.toStringAsFixed(1)} km',
                                                style: AppTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
