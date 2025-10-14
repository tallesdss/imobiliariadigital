import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/property_model.dart';
import '../../theme/app_theme.dart';
import '../../services/property_service.dart';
import '../../services/favorite_service.dart';

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
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _property = widget.property;
      _isLoading = false;
      _checkFavoriteStatus();
    } else if (widget.propertyId != null) {
      _loadProperty(widget.propertyId!);
    } else {
      _error = 'ID do imóvel não fornecido';
      _isLoading = false;
    }
  }

  Future<void> _loadProperty(String propertyId) async {
    try {
      if (kDebugMode) {
        debugPrint('PropertyDetailScreen: Carregando imóvel com ID: $propertyId');
      }
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final property = await PropertyService.getPropertyById(propertyId);
      
      if (kDebugMode) {
        debugPrint('PropertyDetailScreen: Imóvel carregado: ${property.title}');
      }
      
      if (mounted) {
        setState(() {
          _property = property;
          _isLoading = false;
        });
        _checkFavoriteStatus();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PropertyDetailScreen: Erro ao carregar imóvel: $e');
      }
      
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar imóvel: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_property == null) return;
    
    try {
      final favorites = await FavoriteService.getUserFavorites();
      final isFavorite = favorites.any((fav) => fav.id == _property!.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      // Ignorar erro de favoritos
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
            onPressed: _shareProperty,
          ),
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900; // desktop/tablet largo
          if (!isWide) {
            // Layout mobile: coluna única
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(property),
                  _buildMainInfo(property),
                  _buildPriceCard(property),
                  _buildCharacteristics(property),
                  _buildLocation(property),
                  _buildContact(property),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          // Layout desktop: duas colunas
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coluna esquerda (conteúdo)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageGallery(property),
                        _buildMainInfo(property),
                        _buildCharacteristics(property),
                        _buildLocation(property),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Coluna direita (card de preço/ações)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildPriceCard(property),
                        const SizedBox(height: 16),
                        _buildVerificationCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(property),
    );
  }

  Widget _buildImageGallery(Property property) {
    // Galeria com imagem destacada e miniaturas, semelhante ao exemplo
    final photos = property.photos;
    if (photos.isEmpty) {
      return Container(
        height: 280,
        color: Colors.grey[200],
        margin: const EdgeInsets.only(bottom: 16),
        child: const Center(
          child: Icon(Icons.home, size: 80, color: Colors.grey),
        ),
      );
    }

    final mainPhoto = photos.first;
    final thumbs = photos.skip(1).take(5).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                mainPhoto,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.home, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (thumbs.isNotEmpty)
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: thumbs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = thumbs[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AspectRatio(
                      aspectRatio: 1.4,
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
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
              const SizedBox(width: 12),
              if (property.transactionType != null)
                Chip(
                  label: Text(
                    _getTransactionTypeLabel(property.transactionType!),
                    style: AppTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Property property) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.formattedPrice,
              style: AppTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (property.condominium > 0)
              Text(
                'Condomínio: R\$ ${property.condominium.toStringAsFixed(0)} / mês',
                style: AppTheme.bodyMedium,
              ),
            if (property.iptu > 0) ...[
              const SizedBox(height: 4),
              Text(
                'IPTU: R\$ ${property.iptu.toStringAsFixed(0)} / mês',
                style: AppTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _makePhoneCall(property.realtorPhone),
                icon: const Icon(Icons.phone),
                label: const Text('Exibir telefone'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openWhatsApp(property.realtorPhone, property.title),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Novo'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Esta conta passou por um processo de validação de identidade'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Saiba mais'),
            ),
          ],
        ),
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
              onPressed: () => _makePhoneCall(property.realtorPhone),
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
              onPressed: () => _openWhatsApp(property.realtorPhone, property.title),
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

  Future<void> _toggleFavorite() async {
    if (_property == null) return;

    try {
      await FavoriteService.toggleFavorite(_property!.id);
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? 'Imóvel adicionado aos favoritos'
                  : 'Imóvel removido dos favoritos',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar favorito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareProperty() async {
    if (_property == null) return;

    try {
      final shareText = '''
🏠 ${_property!.title}

💰 ${_property!.formattedPrice}
📍 ${_property!.address}, ${_property!.city} - ${_property!.state}

${_property!.description}

📱 Confira este imóvel no SC Imóveis!
      ''';

      // Usar o SharePlus para compartilhamento
      // await Share.share(shareText);
      
      // Por enquanto, mostrar um dialog com o texto para compartilhar
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Compartilhar Imóvel'),
            content: SelectableText(shareText),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Usar url_launcher para fazer ligação
      // final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      // await launchUrl(phoneUri);
      
      // Por enquanto, mostrar um dialog com o número
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ligar'),
            content: Text('Deseja ligar para $phoneNumber?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ligando para $phoneNumber...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Ligar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer ligação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String propertyTitle) async {
    try {
      final message = 'Olá! Tenho interesse no imóvel: $propertyTitle';
      
      // Usar url_launcher para abrir WhatsApp
      // final Uri whatsappUri = Uri.parse('https://wa.me/55$cleanNumber?text=${Uri.encodeComponent(message)}');
      // await launchUrl(whatsappUri);
      
      // Por enquanto, mostrar um dialog com as informações
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('WhatsApp'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Número: $phoneNumber'),
                const SizedBox(height: 8),
                Text('Mensagem: $message'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abrindo WhatsApp...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Abrir WhatsApp'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}