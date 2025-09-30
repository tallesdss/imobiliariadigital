import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../models/favorite_model.dart';
import '../../widgets/common/media_gallery.dart';
import 'user_chat_screen.dart';

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

  void _shareProperty() async {
    if (_property == null) return;

    final text = '''
${_property!.title}

${_property!.formattedPrice}
${_property!.typeDisplayName}

${_property!.address}, ${_property!.city} - ${_property!.state}

Características:
${_property!.attributes['bedrooms'] != null ? '• ${_property!.attributes['bedrooms']} quartos\n' : ''}${_property!.attributes['bathrooms'] != null ? '• ${_property!.attributes['bathrooms']} banheiros\n' : ''}${_property!.attributes['area'] != null ? '• ${_property!.attributes['area']}m² de área\n' : ''}${_property!.attributes['parking'] != null ? '• ${_property!.attributes['parking']} vagas\n' : ''}
Contato: ${_property!.realtorName} - ${_property!.realtorPhone}
''';

    try {
      await Share.share(
        text,
        subject: _property!.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao compartilhar imóvel'),
          ),
        );
      }
    }
  }

  void _contactRealtor() async {
    if (_property == null) return;

    final phone = _property!.realtorPhone.replaceAll(RegExp(r'[^\d]'), '');
    final message = 'Olá! Tenho interesse no imóvel: ${_property!.title}';
    final whatsappUrl = Uri.parse('https://wa.me/55$phone?text=${Uri.encodeComponent(message)}');
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('WhatsApp não disponível - ${_property!.realtorName} - $phone'),
              action: SnackBarAction(
                label: 'Copiar',
                onPressed: () => _copyToClipboard(phone),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir WhatsApp - ${_property!.realtorName} - $phone'),
            action: SnackBarAction(
              label: 'Copiar',
              onPressed: () => _copyToClipboard(phone),
            ),
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copiado para a área de transferência'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao copiar para a área de transferência'),
          ),
        );
      }
    }
  }

  void _openMap() async {
    if (_property == null) return;

    final address = '${_property!.address}, ${_property!.city}, ${_property!.state}, ${_property!.zipCode}';
    final encodedAddress = Uri.encodeComponent(address);
    
    // Tenta abrir no Google Maps
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o mapa'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir o mapa'),
          ),
        );
      }
    }
  }

  void _openInternalChat() {
    if (_property == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserChatScreen(),
      ),
    );
  }

  void _createAlert() {
    if (_property == null) return;

    showDialog(
      context: context,
      builder: (context) => CreatePropertyAlertDialog(
        property: _property!,
        onAlertCreated: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta criado com sucesso!'),
            ),
          );
        },
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
                _buildActionButtons(),
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
        background: MediaGallery(
          photos: _property!.photos,
          videos: _property!.videos,
        ),
      ),
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

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações',
            style: AppTypography.h6,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _createAlert,
                  icon: const Icon(Icons.add_alert),
                  label: const Text('Criar Alerta'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    foregroundColor: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareProperty,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
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
              onPressed: _openMap,
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
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openInternalChat,
              icon: const Icon(Icons.chat_bubble),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                foregroundColor: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _contactRealtor,
              icon: const Icon(Icons.message),
              label: const Text('WhatsApp'),
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

class CreatePropertyAlertDialog extends StatefulWidget {
  final Property property;
  final VoidCallback onAlertCreated;

  const CreatePropertyAlertDialog({
    super.key,
    required this.property,
    required this.onAlertCreated,
  });

  @override
  State<CreatePropertyAlertDialog> createState() => _CreatePropertyAlertDialogState();
}

class _CreatePropertyAlertDialogState extends State<CreatePropertyAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetPriceController = TextEditingController();
  AlertType _selectedType = AlertType.priceReduction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Alerta'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações do imóvel
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property.title,
                      style: AppTypography.subtitle2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.property.formattedPrice,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tipo de Alerta',
                style: AppTypography.subtitle2,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<AlertType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: AlertType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAlertDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              if (_selectedType == AlertType.priceReduction) ...[
                const SizedBox(height: 16),
                Text(
                  'Preço Alvo (R\$)',
                  style: AppTypography.subtitle2,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetPriceController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Digite o preço desejado',
                    helperText: 'Preço atual: ${widget.property.formattedPrice}',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o preço alvo';
                    }
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Digite um valor válido';
                    }
                    if (price >= widget.property.price) {
                      return 'O preço alvo deve ser menor que o atual';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createAlert,
          child: const Text('Criar Alerta'),
        ),
      ],
    );
  }

  String _getAlertDisplayName(AlertType type) {
    switch (type) {
      case AlertType.priceReduction:
        return 'Redução de Preço';
      case AlertType.sold:
        return 'Imóvel Vendido';
      case AlertType.newSimilar:
        return 'Imóvel Similar';
    }
  }

  void _createAlert() {
    if (_formKey.currentState!.validate()) {
      final alert = PropertyAlert(
        id: '',
        userId: 'user1',
        propertyId: widget.property.id,
        propertyTitle: widget.property.title,
        type: _selectedType,
        targetPrice: _selectedType == AlertType.priceReduction
            ? double.tryParse(_targetPriceController.text)
            : null,
        createdAt: DateTime.now(),
      );

      MockDataService.addAlert(alert);
      widget.onAlertCreated();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    super.dispose();
  }
}
