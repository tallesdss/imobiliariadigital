import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/property_model.dart';
import '../../models/realtor_model.dart';
import '../../services/property_service.dart';
import '../../services/realtor_service.dart';
import '../../services/upload_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_drawer.dart';

class AdminPropertyFormScreen extends StatefulWidget {
  final Property? property; // Se for edição, passa o imóvel existente

  const AdminPropertyFormScreen({super.key, this.property});

  @override
  State<AdminPropertyFormScreen> createState() => _AdminPropertyFormScreenState();
}

class _AdminPropertyFormScreenState extends State<AdminPropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _areaController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _garageController = TextEditingController();
  final _condoFeeController = TextEditingController();
  final _iptuController = TextEditingController();
  final _commercialAreaController = TextEditingController();
  final _parkingSpacesController = TextEditingController();
  final _elevatorsController = TextEditingController();
  final _floorsController = TextEditingController();

  PropertyType _selectedType = PropertyType.apartment;
  PropertyStatus _selectedStatus = PropertyStatus.active;
  PropertyTransactionType? _selectedTransactionType;
  PropertyCategory? _selectedCategory;
  List<PropertyTag> _selectedTags = [];
  String? _selectedRealtorId;

  List<String> _selectedPhotos = [];
  List<String> _selectedVideos = [];
  List<Realtor> _realtors = [];
  
  bool _isSaving = false;
  bool _isFeatured = false;
  bool _isLaunch = false;
  bool _acceptsProposal = false;
  bool _hasFinancing = false;

  @override
  void initState() {
    super.initState();
    _loadRealtors();
    if (widget.property != null) {
      _loadPropertyData();
    }
  }

  Future<void> _loadRealtors() async {
    try {
      final realtors = await RealtorService.getActiveRealtors();
      setState(() {
        _realtors = realtors;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar corretores: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _loadPropertyData() {
    final property = widget.property!;
    _titleController.text = property.title;
    _descriptionController.text = property.description;
    _priceController.text = property.price.toString();
    _addressController.text = property.address;
    _cityController.text = property.city;
    _stateController.text = property.state;
    _zipCodeController.text = property.zipCode;
    _areaController.text = property.attributes['area']?.toString() ?? '';
    _bedroomsController.text = property.attributes['bedrooms']?.toString() ?? '';
    _bathroomsController.text = property.attributes['bathrooms']?.toString() ?? '';
    _garageController.text = property.attributes['garage']?.toString() ?? '';
    _condoFeeController.text = property.attributes['condo_fee']?.toString() ?? '';
    _iptuController.text = property.attributes['iptu']?.toString() ?? '';
    _commercialAreaController.text = property.attributes['commercial_area']?.toString() ?? '';
    _parkingSpacesController.text = property.attributes['parking_spaces']?.toString() ?? '';
    _elevatorsController.text = property.attributes['elevators']?.toString() ?? '';
    _floorsController.text = property.attributes['floors']?.toString() ?? '';
    
    _selectedType = property.type;
    _selectedStatus = property.status;
    _selectedTransactionType = property.transactionType;
    _selectedCategory = property.category;
    _selectedTags = List.from(property.tags);
    _selectedRealtorId = property.realtorId;
    _selectedPhotos = List.from(property.photos);
    _selectedVideos = List.from(property.videos);
    
    _isFeatured = property.isFeatured;
    _isLaunch = property.isLaunch;
    _acceptsProposal = property.attributes['accepts_proposal'] == true;
    _hasFinancing = property.attributes['has_financing'] == true;
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
    _areaController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _garageController.dispose();
    _condoFeeController.dispose();
    _iptuController.dispose();
    _commercialAreaController.dispose();
    _parkingSpacesController.dispose();
    _elevatorsController.dispose();
    _floorsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property != null ? 'Editar Imóvel' : 'Cadastrar Imóvel'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          TextButton(
            onPressed: _saveProperty,
            child: Text(
              'Salvar',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(
        userType: DrawerUserType.admin,
        userName: 'Administrador',
        userEmail: 'admin@imobiliaria.com',
        currentRoute: '/admin/property/new',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildPropertyDetailsSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildCategoriesAndTagsSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildMediaSection(),
              const SizedBox(height: AppSpacing.xl),
              if (_selectedType == PropertyType.commercial) ...[
                _buildCommercialAttributesSection(),
                const SizedBox(height: AppSpacing.xl),
              ],
              _buildStatusSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Básicas',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Título do Imóvel',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Título é obrigatório';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Descrição é obrigatória';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Preço é obrigatório';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Preço deve ser um número válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child:               DropdownButtonFormField<PropertyType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: PropertyType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getPropertyTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do Imóvel',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Endereço',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Endereço é obrigatório';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cidade é obrigatória';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Estado é obrigatório';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Área (m²)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Área é obrigatória';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Área deve ser um número válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _bedroomsController,
                decoration: const InputDecoration(
                  labelText: 'Quartos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Número de quartos é obrigatório';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Deve ser um número válido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bathroomsController,
                decoration: const InputDecoration(
                  labelText: 'Banheiros',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Número de banheiros é obrigatório';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Deve ser um número válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _garageController,
                decoration: const InputDecoration(
                  labelText: 'Vagas de Garagem',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Número de vagas é obrigatório';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Deve ser um número válido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(
                  labelText: 'CEP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CEP é obrigatório';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _condoFeeController,
                decoration: const InputDecoration(
                  labelText: 'Condomínio (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _iptuController,
                decoration: const InputDecoration(
                  labelText: 'IPTU Mensal (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<PropertyTransactionType>(
                initialValue: _selectedTransactionType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Transação',
                  border: OutlineInputBorder(),
                ),
                items: PropertyTransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTransactionTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTransactionType = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesAndTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias e Tags',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
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
            color: AppColors.textSecondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mídia',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Adicionar Foto'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addMultiplePhotos,
                icon: const Icon(Icons.photo_library),
                label: const Text('Múltiplas Fotos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Adicionar Vídeo'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(), // Espaço vazio para manter layout
            ),
          ],
        ),
        if (_selectedPhotos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Fotos (${_selectedPhotos.length})',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedPhotos[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        if (_selectedVideos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vídeos (${_selectedVideos.length})',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final entry in _selectedVideos.asMap().entries) ...[
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(entry.value)),
                  IconButton(
                    onPressed: () => _removeVideo(entry.key),
                    icon: const Icon(Icons.close, color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildCommercialAttributesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atributos Comerciais',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _commercialAreaController,
                decoration: const InputDecoration(
                  labelText: 'Área Comercial (m²)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _parkingSpacesController,
                decoration: const InputDecoration(
                  labelText: 'Vagas de Estacionamento',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _elevatorsController,
                decoration: const InputDecoration(
                  labelText: 'Número de Elevadores',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _floorsController,
                decoration: const InputDecoration(
                  labelText: 'Número de Andares',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status e Configurações',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<PropertyStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: PropertyStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getPropertyStatusDisplayName(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedRealtorId,
                decoration: const InputDecoration(
                  labelText: 'Corretor Responsável',
                  border: OutlineInputBorder(),
                ),
                items: _realtors.map((realtor) {
                  return DropdownMenuItem(
                    value: realtor.id,
                    child: Text(realtor.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRealtorId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Corretor é obrigatório';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Destaque'),
                subtitle: const Text('Exibir em destaque na home'),
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Lançamento'),
                subtitle: const Text('Marcar como lançamento'),
                value: _isLaunch,
                onChanged: (value) {
                  setState(() {
                    _isLaunch = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Aceita Proposta'),
                subtitle: const Text('Permitir propostas de preço'),
                value: _acceptsProposal,
                onChanged: (value) {
                  setState(() {
                    _acceptsProposal = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Tem Financiamento'),
                subtitle: const Text('Disponível para financiamento'),
                value: _hasFinancing,
                onChanged: (value) {
                  setState(() {
                    _hasFinancing = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              )
            : Text(
                widget.property != null ? 'Atualizar Imóvel' : 'Cadastrar Imóvel',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final url = await UploadService.pickAndUploadImage();
      if (url != null) {
        setState(() {
          _selectedPhotos.add(url);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _addMultiplePhotos() async {
    try {
      final urls = await UploadService.pickAndUploadMultipleImages();
      if (urls.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(urls);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar fotos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    final photoUrl = _selectedPhotos[index];
    setState(() {
      _selectedPhotos.removeAt(index);
    });
    
    // Remove o arquivo do storage em background
    UploadService.deleteFile(photoUrl);
  }

  Future<void> _addVideo() async {
    try {
      final url = await UploadService.pickAndUploadVideo();
      if (url != null) {
        setState(() {
          _selectedVideos.add(url);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar vídeo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeVideo(int index) {
    final videoUrl = _selectedVideos[index];
    setState(() {
      _selectedVideos.removeAt(index);
    });
    
    // Remove o arquivo do storage em background
    UploadService.deleteFile(videoUrl);
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final selectedRealtor = _realtors.firstWhere((r) => r.id == _selectedRealtorId);
      
      // Preparar atributos do imóvel
      final attributes = <String, dynamic>{
        'area': int.tryParse(_areaController.text) ?? 0,
        'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
        'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
        'garage': int.tryParse(_garageController.text) ?? 0,
        'condo_fee': double.tryParse(_condoFeeController.text),
        'iptu': double.tryParse(_iptuController.text),
        'accepts_proposal': _acceptsProposal,
        'has_financing': _hasFinancing,
      };

      // Adicionar atributos específicos para imóveis comerciais
      if (_selectedType == PropertyType.commercial) {
        attributes['commercial_area'] = int.tryParse(_commercialAreaController.text);
        attributes['parking_spaces'] = int.tryParse(_parkingSpacesController.text);
        attributes['elevators'] = int.tryParse(_elevatorsController.text);
        attributes['floors'] = int.tryParse(_floorsController.text);
      }

      final property = Property(
        id: widget.property?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        type: _selectedType,
        status: _selectedStatus,
        transactionType: _selectedTransactionType,
        category: _selectedCategory,
        tags: _selectedTags,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        photos: _selectedPhotos,
        videos: _selectedVideos,
        attributes: attributes,
        realtorId: _selectedRealtorId!,
        realtorName: selectedRealtor.name,
        realtorPhone: selectedRealtor.phone,
        adminContact: 'admin@imobiliariadigital.com',
        createdAt: widget.property?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFeatured: _isFeatured,
        isLaunch: _isLaunch,
      );

      // Salvar no banco de dados
      if (widget.property != null) {
        await PropertyService.updateProperty(property);
      } else {
        await PropertyService.createProperty(property);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.property != null 
                  ? 'Imóvel atualizado com sucesso!' 
                  : 'Imóvel cadastrado com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Voltar para a tela anterior
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar imóvel: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getPropertyTypeDisplayName(PropertyType type) {
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

  String _getPropertyStatusDisplayName(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return 'Ativo';
      case PropertyStatus.sold:
        return 'Vendido';
      case PropertyStatus.archived:
        return 'Arquivado';
      case PropertyStatus.suspended:
        return 'Suspenso';
    }
  }

  String _getTransactionTypeDisplayName(PropertyTransactionType type) {
    switch (type) {
      case PropertyTransactionType.sale:
        return 'Venda';
      case PropertyTransactionType.rent:
        return 'Aluguel';
      case PropertyTransactionType.daily:
        return 'Temporada';
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
}
