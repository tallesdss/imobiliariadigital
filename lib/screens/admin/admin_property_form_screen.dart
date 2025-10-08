import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/mock_data_service.dart';
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
  final _areaController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _garageController = TextEditingController();

  PropertyType _selectedType = PropertyType.apartment;
  PropertyStatus _selectedStatus = PropertyStatus.active;
  String? _selectedRealtorId;

  List<String> _selectedPhotos = [];
  List<String> _selectedVideos = [];

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _loadPropertyData();
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
    _areaController.text = property.attributes['area']?.toString() ?? '';
    _bedroomsController.text = property.attributes['bedrooms']?.toString() ?? '';
    _bathroomsController.text = property.attributes['bathrooms']?.toString() ?? '';
    _garageController.text = property.attributes['garage']?.toString() ?? '';
    _selectedType = property.type;
    _selectedStatus = property.status;
    _selectedRealtorId = property.realtorId;
    _selectedPhotos = List.from(property.photos);
    _selectedVideos = List.from(property.videos);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _areaController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _garageController.dispose();
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
              _buildMediaSection(),
              const SizedBox(height: AppSpacing.xl),
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
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Adicionar Vídeo'),
              ),
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

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status e Corretor',
          style: AppTypography.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child:               DropdownButtonFormField<PropertyStatus>(
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
              child:               DropdownButtonFormField<String>(
                initialValue: _selectedRealtorId,
                decoration: const InputDecoration(
                  labelText: 'Corretor Responsável',
                  border: OutlineInputBorder(),
                ),
                items: MockDataService.realtors.map((realtor) {
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        ),
        child: Text(
          widget.property != null ? 'Atualizar Imóvel' : 'Cadastrar Imóvel',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _addPhoto() {
    // Mock: adicionar foto fake
    setState(() {
      _selectedPhotos.add('https://picsum.photos/400/300?random=${_selectedPhotos.length}');
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _addVideo() {
    // Mock: adicionar vídeo fake
    setState(() {
      _selectedVideos.add('Vídeo ${_selectedVideos.length + 1} - Tour Virtual');
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  void _saveProperty() {
    if (_formKey.currentState!.validate()) {
      // Mock: salvar imóvel
      final selectedRealtor = MockDataService.realtors
          .firstWhere((r) => r.id == _selectedRealtorId);
      
      Property(
        id: widget.property?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        type: _selectedType,
        status: _selectedStatus,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: '00000-000', // Mock zipCode
        photos: _selectedPhotos,
        videos: _selectedVideos,
        attributes: {
          'area': int.parse(_areaController.text),
          'bedrooms': int.parse(_bedroomsController.text),
          'bathrooms': int.parse(_bathroomsController.text),
          'garage': int.parse(_garageController.text),
        },
        realtorId: _selectedRealtorId!,
        realtorName: selectedRealtor.name,
        realtorPhone: selectedRealtor.phone,
        adminContact: 'admin@imobiliariadigital.com',
        createdAt: widget.property?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simular salvamento
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
}
