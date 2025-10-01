import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';

class PropertyComparisonScreen extends StatefulWidget {
  final List<String> propertyIds;

  const PropertyComparisonScreen({super.key, required this.propertyIds});

  @override
  State<PropertyComparisonScreen> createState() =>
      _PropertyComparisonScreenState();
}

class _PropertyComparisonScreenState extends State<PropertyComparisonScreen> {
  List<Property> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final properties = widget.propertyIds
          .map((id) => MockDataService.getPropertyById(id))
          .whereType<Property>()
          .toList();

      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comparação de Imóveis'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
          ? _buildEmptyState()
          : _buildComparisonTable(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.compare_arrows, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Nenhum imóvel para comparar',
            style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Imagens dos imóveis
          _buildPropertyImages(),

          // Tabela de comparação
          _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildPropertyImages() {
    return Container(
      height: 200,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final property = _properties[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(
              right: index == _properties.length - 1 ? 0 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: property.photos.isNotEmpty
                        ? Image.network(
                            property.photos.first,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 32,
                                  color: AppColors.textHint,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(
                              Icons.home_work,
                              size: 32,
                              color: AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  property.title,
                  style: AppTypography.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.1),
          ),
          columns: [
            const DataColumn(
              label: Text(
                'Característica',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ..._properties.map(
              (property) => DataColumn(
                label: SizedBox(
                  width: 120,
                  child: Text(
                    'Imóvel ${_properties.indexOf(property) + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
          rows: [
            _buildDataRow(
              'Preço',
              _properties.map((p) => p.formattedPrice).toList(),
              isHighlight: true,
            ),
            _buildDataRow(
              'Tipo',
              _properties.map((p) => p.typeDisplayName).toList(),
            ),
            _buildDataRow('Cidade', _properties.map((p) => p.city).toList()),
            _buildDataRow(
              'Bairro',
              _properties.map((p) => p.address.split(',').first).toList(),
            ),
            _buildDataRow(
              'Quartos',
              _properties
                  .map((p) => p.attributes['bedrooms']?.toString() ?? '-')
                  .toList(),
            ),
            _buildDataRow(
              'Banheiros',
              _properties
                  .map((p) => p.attributes['bathrooms']?.toString() ?? '-')
                  .toList(),
            ),
            _buildDataRow(
              'Área (m²)',
              _properties
                  .map((p) => p.attributes['area']?.toString() ?? '-')
                  .toList(),
            ),
            _buildDataRow(
              'Vagas',
              _properties
                  .map((p) => p.attributes['parking']?.toString() ?? '-')
                  .toList(),
            ),
            if (_properties.any((p) => p.attributes['floor'] != null))
              _buildDataRow(
                'Andar',
                _properties
                    .map((p) => p.attributes['floor']?.toString() ?? '-')
                    .toList(),
              ),
            if (_properties.any((p) => p.attributes['land_area'] != null))
              _buildDataRow(
                'Terreno (m²)',
                _properties
                    .map((p) => p.attributes['land_area']?.toString() ?? '-')
                    .toList(),
              ),
            _buildDataRow(
              'Status',
              _properties.map((p) => p.status.name).toList(),
            ),
            _buildDataRow(
              'Corretor',
              _properties.map((p) => p.realtorName).toList(),
            ),
            _buildDataRow(
              'Telefone',
              _properties.map((p) => p.realtorPhone).toList(),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(
    String label,
    List<String> values, {
    bool isHighlight = false,
  }) {
    return DataRow(
      color: isHighlight
          ? WidgetStateProperty.all(AppColors.accent.withValues(alpha: 0.05))
          : null,
      cells: [
        DataCell(
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...values.map(
          (value) => DataCell(
            SizedBox(
              width: 120,
              child: Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: isHighlight
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
