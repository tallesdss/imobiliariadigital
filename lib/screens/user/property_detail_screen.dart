import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Property? _property;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  void _loadPropertyDetails() {
    setState(() {
      _isLoading = true;
    });

    // Simular carregamento
    Future.delayed(const Duration(milliseconds: 500), () {
      final property = MockDataService.getPropertyById(widget.propertyId);
      final isFavorite = MockDataService.isPropertyFavorited('user1', widget.propertyId);
      
      setState(() {
        _property = property;
        _isFavorite = isFavorite;
        _isLoading = false;
      });
    });
  }

  void _toggleFavorite() {
    if (_property == null) return;

    setState(() {
      if (_isFavorite) {
        MockDataService.removeFavorite('user1', _property!.id);
        _isFavorite = false;
      } else {
        MockDataService.addFavorite('user1', _property!.id);
        _isFavorite = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite 
              ? 'Imóvel adicionado aos favoritos'
              : 'Imóvel removido dos favoritos',
        ),
      ),
    );
  }

  void _shareProperty() {
    // TODO: Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartilhamento em desenvolvimento'),
      ),
    );
  }

  void _contactRealtor() {
    if (_property == null) return;

    // TODO: Implementar abertura do WhatsApp quando url_launcher estiver disponível
    final phone = _property!.realtorPhone.replaceAll(RegExp(r'[^\d]'), '');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contatar: ${_property!.realtorName} - $phone'),
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () {
            // TODO: Implementar cópia para clipboard
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carregando...'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Imóvel não encontrado'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: const Center(
          child: Text('Imóvel não encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildPropertyInfo(),
                _buildAttributes(),
                _buildDescription(),
                _buildRealtorInfo(),
                _buildLocationInfo(),
                const SizedBox(height: 100), // Espaço para o botão fixo
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      actions: [
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : AppColors.textOnPrimary,
          ),
        ),
        IconButton(
          onPressed: _shareProperty,
          icon: const Icon(Icons.share),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _property!.photos.isNotEmpty
            ? _buildImageCarousel()
            : Container(
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.home_work_outlined,
                  size: 64,
                  color: AppColors.textHint,
                ),
              ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (_property!.photos.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        PageView.builder(
          itemCount: _property!.photos.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.network(
              _property!.photos[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                );
              },
            );
          },
        ),
        if (_property!.photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _property!.photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Cód: ${_property!.id.substring(0, 5)}',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo e preço
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _property!.typeDisplayName,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _property!.formattedPrice,
                style: AppTypography.priceMain,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Título
          Text(
            _property!.title,
            style: AppTypography.h4,
          ),
          const SizedBox(height: 8),
          // Localização
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_property!.address}, ${_property!.city} - ${_property!.state}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributes() {
    final attributes = <Widget>[];
    
    if (_property!.attributes['bedrooms'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.bed_outlined,
        '${_property!.attributes['bedrooms']}',
        _property!.attributes['bedrooms'] == 1 ? 'Quarto' : 'Quartos',
      ));
    }
    
    if (_property!.attributes['bathrooms'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.bathroom_outlined,
        '${_property!.attributes['bathrooms']}',
        _property!.attributes['bathrooms'] == 1 ? 'Banheiro' : 'Banheiros',
      ));
    }
    
    if (_property!.attributes['area'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.square_foot_outlined,
        '${_property!.attributes['area']}m²',
        'Área',
      ));
    }
    
    if (_property!.attributes['parking'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.directions_car_outlined,
        '${_property!.attributes['parking']}',
        _property!.attributes['parking'] == 1 ? 'Vaga' : 'Vagas',
      ));
    }

    if (_property!.attributes['floor'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.layers_outlined,
        '${_property!.attributes['floor']}º',
        'Andar',
      ));
    }

    if (_property!.attributes['land_area'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.landscape_outlined,
        '${_property!.attributes['land_area']}m²',
        'Terreno',
      ));
    }

    if (attributes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Características',
            style: AppTypography.h6,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: attributes,
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(IconData icon, String value, String label) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.labelLarge,
          ),
          Text(
            label,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (_property!.description.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrição',
            style: AppTypography.h6,
          ),
          const SizedBox(height: 12),
          Text(
            _property!.description,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRealtorInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Corretor Responsável',
            style: AppTypography.h6,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  _property!.realtorName.substring(0, 1).toUpperCase(),
                  style: AppTypography.h6.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _property!.realtorName,
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _property!.realtorPhone,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _contactRealtor,
                icon: const Icon(
                  Icons.chat,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Localização',
            style: AppTypography.h6,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _property!.address,
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      '${_property!.city} - ${_property!.state}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'CEP: ${_property!.zipCode}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Abrir mapa
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mapa em desenvolvimento'),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Ver no Mapa'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _contactRealtor,
              icon: const Icon(Icons.phone),
              label: const Text('Ligar'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _contactRealtor,
              icon: const Icon(Icons.chat),
              label: const Text('Conversar pelo WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
