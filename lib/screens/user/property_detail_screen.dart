import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../theme/app_theme.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property? property;
  final String? propertyId;

  const PropertyDetailScreen({
    super.key,
    this.property,
    this.propertyId,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Property? _property;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _property = widget.property;
      _isLoading = false;
    } else if (widget.propertyId != null) {
      _loadProperty(widget.propertyId!);
    } else {
      _error = 'ID do imóvel não fornecido';
      _isLoading = false;
    }
  }

  Future<void> _loadProperty(String propertyId) async {
    try {
      // Aqui você carregaria o imóvel do serviço
      // Por enquanto, vamos simular um erro
      setState(() {
        _error = 'Imóvel não encontrado';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar imóvel: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _property == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(_error ?? 'Imóvel não encontrado'),
        ),
      );
    }

    final property = _property!;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implementar compartilhamento
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Implementar favoritos
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galeria de imagens
            _buildImageGallery(property),
            
            // Informações principais
            _buildMainInfo(property),
            
            // Características
            _buildCharacteristics(property),
            
            // Localização
            _buildLocation(property),
            
            // Contato
            _buildContact(property),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(property),
    );
  }

  Widget _buildImageGallery(Property property) {
    return SizedBox(
      height: 300,
      child: property.photos.isNotEmpty
          ? PageView.builder(
              itemCount: property.photos.length,
              itemBuilder: (context, index) {
                return Image.network(
                  property.photos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.home,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                );
              },
            )
          : Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.home,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }

  Widget _buildMainInfo(Property property) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: AppTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.description,
            style: AppTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                property.formattedPrice,
                style: AppTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (property.transactionType != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getTransactionTypeLabel(property.transactionType!),
                    style: AppTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristics(Property property) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características',
              style: AppTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCharacteristic(
                  Icons.bed,
                  'Quartos',
                  '${property.attributes['bedrooms'] ?? 0}',
                ),
                _buildCharacteristic(
                  Icons.bathtub,
                  'Banheiros',
                  '${property.attributes['bathrooms'] ?? 0}',
                ),
                _buildCharacteristic(
                  Icons.square_foot,
                  'Área',
                  '${property.attributes['area'] ?? 0}m²',
                ),
                _buildCharacteristic(
                  Icons.local_parking,
                  'Vagas',
                  '${property.attributes['parking_spaces'] ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristic(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocation(Property property) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Localização',
              style: AppTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.address,
                        style: AppTheme.bodyLarge,
                      ),
                      Text(
                        '${property.city}, ${property.state}',
                        style: AppTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContact(Property property) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contato',
              style: AppTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    property.realtorName.isNotEmpty 
                        ? property.realtorName[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.realtorName,
                        style: AppTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        property.realtorPhone,
                        style: AppTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Property property) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Implementar ligação
              },
              icon: const Icon(Icons.phone),
              label: const Text('Ligar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Implementar WhatsApp
              },
              icon: const Icon(Icons.message),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(PropertyTransactionType type) {
    switch (type) {
      case PropertyTransactionType.sale:
        return 'Venda';
      case PropertyTransactionType.rent:
        return 'Aluguel';
      case PropertyTransactionType.daily:
        return 'Temporada';
    }
  }
}