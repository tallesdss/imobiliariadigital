import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class PropertyFormScreen extends StatefulWidget {
  final Property? property;

  const PropertyFormScreen({super.key, this.property});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _parkingController = TextEditingController();

  PropertyType _selectedType = PropertyType.apartment;
  PropertyStatus _selectedStatus = PropertyStatus.active;
  PropertyCategory? _selectedCategory;
  List<PropertyTag> _selectedTags = [];
  bool _isFeatured = false;
  bool _isLaunch = false;
  List<String> _photos = [];
  List<String> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final property = widget.property!;
    _titleController.text = property.title;
    _descriptionController.text = property.description;
    _priceController.text = property.price.toString();
    _addressController.text = property.address;
    _cityController.text = property.city;
    _stateController.text = property.state;
    _zipCodeController.text = property.zipCode;
    _selectedType = property.type;
    _selectedStatus = property.status;
    _selectedCategory = property.category;
    _selectedTags = List.from(property.tags);
    _isFeatured = property.isFeatured;
    _isLaunch = property.isLaunch;
    _photos = List.from(property.photos);
    _videos = List.from(property.videos);

    if (property.attributes['bedrooms'] != null) {
      _bedroomsController.text = property.attributes['bedrooms'].toString();
    }
    if (property.attributes['bathrooms'] != null) {
      _bathroomsController.text = property.attributes['bathrooms'].toString();
    }
    if (property.attributes['area'] != null) {
      _areaController.text = property.attributes['area'].toString();
    }
    if (property.attributes['parking'] != null) {
      _parkingController.text = property.attributes['parking'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.property == null ? 'Cadastrar Imóvel' : 'Editar Imóvel',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildLocationSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildAttributesSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildCategoriesAndTagsSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildMediaSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações Básicas', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _titleController,
            label: 'Título',
            validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PropertyType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: PropertyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _priceController,
                  label: 'Preço',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Obrigatório' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Localização', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            controller: _addressController,
            label: 'Endereço',
            validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  controller: _cityController,
                  label: 'Cidade',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Obrigatório' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _stateController,
                  label: 'Estado',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Obrigatório' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _zipCodeController,
                  label: 'CEP',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Características', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _bedroomsController,
                  label: 'Quartos',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _bathroomsController,
                  label: 'Banheiros',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _areaController,
                  label: 'Área (m²)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _parkingController,
                  label: 'Vagas',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesAndTagsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categorias e Tags', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.lg),
          
          // Categoria
          DropdownButtonFormField<PropertyCategory>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(),
              helperText: 'Selecione a categoria do imóvel',
            ),
            items: PropertyCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryDisplayName(category)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Tags
          Text(
            'Tags',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Selecione as tags que se aplicam ao imóvel:',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Tags organizadas por categoria
          _buildTagCategory('Destaque', [
            PropertyTag.featured,
            PropertyTag.launch,
            PropertyTag.newProperty,
            PropertyTag.hotDeal,
            PropertyTag.exclusive,
          ]),
          
          _buildTagCategory('Características', [
            PropertyTag.furnished,
            PropertyTag.unfurnished,
            PropertyTag.petFriendly,
            PropertyTag.hasPool,
            PropertyTag.hasGym,
            PropertyTag.hasSecurity,
            PropertyTag.hasGarage,
            PropertyTag.hasGarden,
            PropertyTag.hasBalcony,
            PropertyTag.hasElevator,
          ]),
          
          _buildTagCategory('Localização', [
            PropertyTag.nearMetro,
            PropertyTag.nearSchool,
            PropertyTag.nearHospital,
            PropertyTag.nearShopping,
            PropertyTag.beachfront,
            PropertyTag.downtown,
            PropertyTag.quietArea,
          ]),
          
          _buildTagCategory('Financiamento', [
            PropertyTag.acceptsProposal,
            PropertyTag.hasFinancing,
            PropertyTag.cashOnly,
            PropertyTag.rentToOwn,
          ]),
          
          _buildTagCategory('Urgência', [
            PropertyTag.urgent,
            PropertyTag.priceReduced,
            PropertyTag.motivatedSeller,
          ]),
          
          _buildTagCategory('Especiais', [
            PropertyTag.heritage,
            PropertyTag.ecoFriendly,
            PropertyTag.smartHome,
            PropertyTag.renovated,
            PropertyTag.needsRenovation,
          ]),
          
          // Tags selecionadas
          if (_selectedTags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tags Selecionadas (${_selectedTags.length})',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _selectedTags.map((tag) {
                return Chip(
                  label: Text(_getTagDisplayName(tag)),
                  onDeleted: () {
                    setState(() {
                      _selectedTags.remove(tag);
                    });
                  },
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  deleteIconColor: AppColors.primary,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagCategory(String categoryName, List<PropertyTag> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          categoryName,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: tags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(_getTagDisplayName(tag)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Mídia', style: AppTypography.h6),
              const Spacer(),
              TextButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add_photo_alternate, size: 16),
                label: const Text('Foto'),
              ),
              TextButton.icon(
                onPressed: _addVideo,
                icon: const Icon(Icons.videocam, size: 16),
                label: const Text('Vídeo'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_photos.isNotEmpty || _videos.isNotEmpty) ...[
            if (_photos.isNotEmpty) ...[
              Text('Fotos (${_photos.length})'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _photos.asMap().entries.map((entry) {
                  return _buildMediaPreview(entry.value, true, entry.key);
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_videos.isNotEmpty) ...[
              Text('Vídeos (${_videos.length})'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _videos.asMap().entries.map((entry) {
                  return _buildMediaPreview(entry.value, false, entry.key);
                }).toList(),
              ),
            ],
          ] else
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Nenhuma mídia adicionada')),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(String url, bool isPhoto, int index) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image);
                    },
                  ),
                )
              : const Icon(Icons.play_circle_filled, color: AppColors.primary),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isPhoto) {
                  _photos.removeAt(index);
                } else {
                  _videos.removeAt(index);
                }
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: widget.property == null ? 'Cadastrar' : 'Salvar',
        onPressed: _saveProperty,
        isLoading: _isLoading,
      ),
    );
  }

  void _addPhoto() {
    _showAddMediaDialog('Adicionar Foto', 'URL da foto', (url) {
      setState(() {
        _photos.add(url);
      });
    });
  }

  void _addVideo() {
    _showAddMediaDialog('Adicionar Vídeo', 'URL do vídeo', (url) {
      setState(() {
        _videos.add(url);
      });
    });
  }

  void _showAddMediaDialog(String title, String hint, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final attributes = <String, dynamic>{};
    if (_bedroomsController.text.isNotEmpty) {
      attributes['bedrooms'] = int.tryParse(_bedroomsController.text) ?? 0;
    }
    if (_bathroomsController.text.isNotEmpty) {
      attributes['bathrooms'] = int.tryParse(_bathroomsController.text) ?? 0;
    }
    if (_areaController.text.isNotEmpty) {
      attributes['area'] = int.tryParse(_areaController.text) ?? 0;
    }
    if (_parkingController.text.isNotEmpty) {
      attributes['parking'] = int.tryParse(_parkingController.text) ?? 0;
    }

    await Future.delayed(const Duration(seconds: 1));

    final property = Property(
      id: widget.property?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      type: _selectedType,
      status: _selectedStatus,
      category: _selectedCategory,
      tags: _selectedTags,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      photos: _photos,
      videos: _videos,
      attributes: attributes,
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: widget.property?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isFeatured: _isFeatured,
      isLaunch: _isLaunch,
    );

    if (widget.property == null) {
      MockDataService.addProperty(property);
    } else {
      MockDataService.updateProperty(property);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _getCategoryDisplayName(PropertyCategory category) {
    switch (category) {
      case PropertyCategory.residential:
        return 'Residencial';
      case PropertyCategory.commercial:
        return 'Comercial';
      case PropertyCategory.industrial:
        return 'Industrial';
      case PropertyCategory.rural:
        return 'Rural';
      case PropertyCategory.luxury:
        return 'Luxo';
      case PropertyCategory.investment:
        return 'Investimento';
      case PropertyCategory.vacation:
        return 'Férias';
      case PropertyCategory.student:
        return 'Estudante';
    }
  }

  String _getTagDisplayName(PropertyTag tag) {
    switch (tag) {
      // Tags de destaque
      case PropertyTag.featured:
        return 'Destaque';
      case PropertyTag.launch:
        return 'Lançamento';
      case PropertyTag.newProperty:
        return 'Novo';
      case PropertyTag.hotDeal:
        return 'Oferta Quente';
      case PropertyTag.exclusive:
        return 'Exclusivo';
      
      // Tags de características
      case PropertyTag.furnished:
        return 'Mobiliado';
      case PropertyTag.unfurnished:
        return 'Não Mobiliado';
      case PropertyTag.petFriendly:
        return 'Pet Friendly';
      case PropertyTag.hasPool:
        return 'Com Piscina';
      case PropertyTag.hasGym:
        return 'Com Academia';
      case PropertyTag.hasSecurity:
        return 'Com Segurança';
      case PropertyTag.hasGarage:
        return 'Com Garagem';
      case PropertyTag.hasGarden:
        return 'Com Jardim';
      case PropertyTag.hasBalcony:
        return 'Com Varanda';
      case PropertyTag.hasElevator:
        return 'Com Elevador';
      
      // Tags de localização
      case PropertyTag.nearMetro:
        return 'Próximo ao Metrô';
      case PropertyTag.nearSchool:
        return 'Próximo à Escola';
      case PropertyTag.nearHospital:
        return 'Próximo ao Hospital';
      case PropertyTag.nearShopping:
        return 'Próximo ao Shopping';
      case PropertyTag.beachfront:
        return 'Frente para o Mar';
      case PropertyTag.downtown:
        return 'Centro';
      case PropertyTag.quietArea:
        return 'Área Tranquila';
      
      // Tags de financiamento
      case PropertyTag.acceptsProposal:
        return 'Aceita Proposta';
      case PropertyTag.hasFinancing:
        return 'Tem Financiamento';
      case PropertyTag.cashOnly:
        return 'Apenas à Vista';
      case PropertyTag.rentToOwn:
        return 'Renda para Compra';
      
      // Tags de urgência
      case PropertyTag.urgent:
        return 'Urgente';
      case PropertyTag.priceReduced:
        return 'Preço Reduzido';
      case PropertyTag.motivatedSeller:
        return 'Vendedor Motivado';
      
      // Tags especiais
      case PropertyTag.heritage:
        return 'Patrimônio';
      case PropertyTag.ecoFriendly:
        return 'Eco-Friendly';
      case PropertyTag.smartHome:
        return 'Casa Inteligente';
      case PropertyTag.renovated:
        return 'Reformado';
      case PropertyTag.needsRenovation:
        return 'Precisa Reforma';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _parkingController.dispose();
    super.dispose();
  }
}
