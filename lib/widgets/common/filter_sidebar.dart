import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../models/filter_model.dart';

class FilterSidebar extends StatefulWidget {
  final PropertyFilters filters;
  final Function(PropertyFilters) onFiltersChanged;
  final VoidCallback onClearFilters;

  const FilterSidebar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  late PropertyFilters _currentFilters;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _maxCondominiumController = TextEditingController();
  final TextEditingController _maxIptuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
    _updateControllers();
  }

  @override
  void didUpdateWidget(FilterSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      _currentFilters = widget.filters;
      _updateControllers();
    }
  }

  void _updateControllers() {
    _minPriceController.text = _currentFilters.minPrice?.toStringAsFixed(0) ?? '';
    _maxPriceController.text = _currentFilters.maxPrice?.toStringAsFixed(0) ?? '';
    _maxCondominiumController.text = _currentFilters.maxCondominium?.toStringAsFixed(0) ?? '';
    _maxIptuController.text = _currentFilters.maxIptu?.toStringAsFixed(0) ?? '';
  }

  void _updateFilters() {
    widget.onFiltersChanged(_currentFilters);
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = const PropertyFilters();
      _updateControllers();
    });
    widget.onClearFilters();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _maxCondominiumController.dispose();
    _maxIptuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      width: isTablet ? 320 : 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: AppColors.textOnPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Filtros',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_currentFilters.hasActiveFilters)
                  IconButton(
                    onPressed: _clearFilters,
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                    tooltip: 'Limpar filtros',
                  ),
              ],
            ),
          ),
          
          // Filtros
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceFilters(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildTransactionTypeFilters(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPriceRangeFilters(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildAdditionalFilters(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildCondominiumAndIptuFilters(),
                ],
              ),
            ),
          ),
          
          // Botão aplicar
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 16 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Aplicar Filtros',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💰 Filtros de Preço',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Preço mínimo
        Text(
          'Preço mínimo',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _minPriceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 100000',
            prefixText: 'R\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            final price = double.tryParse(value);
            _currentFilters = _currentFilters.copyWith(
              minPrice: price,
            );
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Preço máximo
        Text(
          'Preço máximo',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _maxPriceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 500000',
            prefixText: 'R\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            final price = double.tryParse(value);
            _currentFilters = _currentFilters.copyWith(
              maxPrice: price,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionTypeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de negociação',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        _buildFilterChip(
          'Venda',
          TransactionType.sale,
          _currentFilters.transactionType == TransactionType.sale,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFilterChip(
          'Aluguel',
          TransactionType.rent,
          _currentFilters.transactionType == TransactionType.rent,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFilterChip(
          'Temporada / Diária',
          TransactionType.daily,
          _currentFilters.transactionType == TransactionType.daily,
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Faixas de preço sugeridas',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        ...PriceRange.predefinedRanges.map((range) {
          final isSelected = _currentFilters.priceRanges.contains(range.label);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildFilterChip(
              range.label,
              range.label,
              isSelected,
              onTap: () {
                setState(() {
                  final newRanges = List<String>.from(_currentFilters.priceRanges);
                  if (isSelected) {
                    newRanges.remove(range.label);
                  } else {
                    newRanges.add(range.label);
                  }
                  _currentFilters = _currentFilters.copyWith(
                    priceRanges: newRanges,
                  );
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros adicionais',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        _buildSwitchTile(
          'Parcelamento / Financiamento disponível',
          _currentFilters.hasFinancing,
          (value) {
            _currentFilters = _currentFilters.copyWith(hasFinancing: value);
          },
        ),
        _buildSwitchTile(
          'Aceita proposta / Negociável',
          _currentFilters.acceptProposal,
          (value) {
            _currentFilters = _currentFilters.copyWith(acceptProposal: value);
          },
        ),
        _buildSwitchTile(
          'Exibir apenas imóveis com preço informado',
          _currentFilters.showOnlyWithPrice,
          (value) {
            _currentFilters = _currentFilters.copyWith(showOnlyWithPrice: value);
          },
        ),
      ],
    );
  }

  Widget _buildCondominiumAndIptuFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valores mensais',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Valor do condomínio
        Text(
          'Valor do condomínio',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _maxCondominiumController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 500',
            prefixText: 'R\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            final price = double.tryParse(value);
            _currentFilters = _currentFilters.copyWith(
              maxCondominium: price,
            );
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Valor do IPTU
        Text(
          'Valor do IPTU mensal',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _maxIptuController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 200',
            prefixText: 'R\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            final price = double.tryParse(value);
            _currentFilters = _currentFilters.copyWith(
              maxIptu: price,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, dynamic value, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        setState(() {
          if (value is TransactionType) {
            _currentFilters = _currentFilters.copyWith(
              transactionType: isSelected ? null : value,
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                size: 16,
                color: AppColors.primary,
              ),
            if (isSelected) const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
