import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_breakpoints.dart';
import '../../models/filter_model.dart';
import '../../models/property_model.dart';
import 'custom_drawer.dart';

enum SidebarType { navigation, filters, combined }

class FixedSidebar extends StatelessWidget {
  final SidebarType type;
  final DrawerUserType? userType; // Para navegação
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final String? userCreci;
  final String currentRoute;
  
  // Para filtros
  final PropertyFilters? filters;
  final Function(PropertyFilters)? onFiltersChanged;
  final VoidCallback? onClearFilters;
  
  // Controle de visibilidade
  final bool isVisible;
  final VoidCallback? onToggleVisibility;

  const FixedSidebar({
    super.key,
    required this.type,
    required this.currentRoute,
    this.userType,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.userCreci,
    this.filters,
    this.onFiltersChanged,
    this.onClearFilters,
    this.isVisible = true,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    // Em mobile, usar drawer ao invés de sidebar fixa
    if (context.isMobile) {
      return const SizedBox.shrink(); // Será renderizado como drawer
    }
    
    if (!isVisible) {
      return Container(
        width: 60,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            right: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: IconButton(
                onPressed: onToggleVisibility,
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == SidebarType.filters 
                        ? Icons.filter_list 
                        : Icons.menu,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: context.sidebarWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (onToggleVisibility != null)
            IconButton(
              onPressed: onToggleVisibility,
              icon: const Icon(
                Icons.close,
                color: AppColors.textOnPrimary,
              ),
            ),
          Expanded(
            child: Text(
              _getHeaderTitle(),
              style: AppTypography.h6.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (type == SidebarType.filters && filters?.hasActiveFilters == true)
            IconButton(
              onPressed: onClearFilters,
              icon: const Icon(
                Icons.clear,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
              tooltip: 'Limpar filtros',
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (type) {
      case SidebarType.navigation:
        return _buildNavigationContent(context);
      case SidebarType.filters:
        return _buildFiltersContent(context);
      case SidebarType.combined:
        return _buildCombinedContent(context);
    }
  }

  Widget _buildNavigationContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header do usuário
          if (userName != null && userEmail != null)
            _buildUserHeader(context),
          
          // Menu items
          ..._buildMenuItems(context),
          const Divider(),
          _buildDevelopmentSection(context),
          const Divider(),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildFiltersContent(BuildContext context) {
    if (filters == null || onFiltersChanged == null) {
      return const Center(
        child: Text('Filtros não disponíveis'),
      );
    }

    return FilterSidebarContent(
      filters: filters!,
      onFiltersChanged: onFiltersChanged!,
      onClearFilters: onClearFilters ?? () {},
      userType: userType,
    );
  }

  Widget _buildCombinedContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header do usuário
          if (userName != null && userEmail != null)
            _buildUserHeader(context),
          
          // Menu items
          ..._buildMenuItems(context),
          const Divider(),
          _buildDevelopmentSection(context),
          const Divider(),
          
          // Filtros
          if (filters != null && onFiltersChanged != null)
            FilterSidebarContent(
              filters: filters!,
              onFiltersChanged: onFiltersChanged!,
              onClearFilters: onClearFilters ?? () {},
              userType: userType,
            ),
          
          const Divider(),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: context.isTablet ? 32 : 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: userAvatar != null
                    ? NetworkImage(userAvatar!)
                    : null,
                child: userAvatar == null
                    ? Text(
                        userName?.isNotEmpty == true ? userName![0].toUpperCase() : '?',
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  userType == DrawerUserType.realtor
                      ? 'Corretor'
                      : 'Administrador',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            userName ?? '',
            style: AppTypography.h6.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail ?? '',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (userCreci != null) ...[
            const SizedBox(height: 4),
            Text(
              userCreci!,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    if (userType == null) return [];

    if (userType == DrawerUserType.realtor) {
      return [
        _buildMenuItem(
          context,
          Icons.home_outlined,
          'Meus Imóveis',
          '/realtor',
          '/realtor',
        ),
        _buildMenuItem(
          context,
          Icons.add_business_outlined,
          'Cadastrar Imóvel',
          '/realtor/property/new',
          '/realtor/property/new',
        ),
        _buildMenuItem(
          context,
          Icons.person_outline,
          'Meu Perfil',
          '/realtor/profile',
          '/realtor/profile',
        ),
        _buildMenuItem(
          context,
          Icons.chat_bubble_outline,
          'Mensagens',
          '/realtor/chat',
          '/realtor/chat',
        ),
        const Divider(),
        _buildMenuItem(
          context,
          Icons.analytics_outlined,
          'Relatórios',
          '/realtor/reports',
          '/realtor/reports',
        ),
        _buildMenuItem(
          context,
          Icons.help_outline,
          'Ajuda',
          '/realtor/help',
          '/realtor/help',
        ),
      ];
    } else {
      return [
        _buildMenuItem(
          context,
          Icons.dashboard_outlined,
          'Dashboard',
          '/admin/dashboard',
          '/admin/dashboard',
        ),
        _buildMenuItem(
          context,
          Icons.home_work_outlined,
          'Gestão de Imóveis',
          '/admin',
          '/admin',
        ),
        _buildMenuItem(
          context,
          Icons.people_outline,
          'Gestão de Corretores',
          '/admin/realtors',
          '/admin/realtors',
        ),
        _buildMenuItem(
          context,
          Icons.add_business_outlined,
          'Cadastrar Imóvel',
          '/admin/property/new',
          '/admin/property/new',
        ),
        _buildMenuItem(
          context,
          Icons.chat_bubble_outline,
          'Mensagens',
          '/admin/chat',
          '/admin/chat',
        ),
        const Divider(),
        _buildMenuItem(
          context,
          Icons.analytics_outlined,
          'Relatórios',
          '/admin/reports',
          '/admin/reports',
        ),
        _buildMenuItem(
          context,
          Icons.settings_outlined,
          'Configurações',
          '/admin/settings',
          '/admin/settings',
        ),
        _buildMenuItem(
          context,
          Icons.help_outline,
          'Ajuda',
          '/admin/help',
          '/admin/help',
        ),
      ];
    }
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route, String routeName) {
    final isSelected = currentRoute == route || currentRoute == routeName;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          GoRouter.of(context).go(route);
        },
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDevelopmentSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.developer_mode,
                color: AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Desenvolvimento',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Navegação rápida entre tipos de usuário:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDevButton(
                  context,
                  'Comprador',
                  '/user',
                  Icons.person_outline,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDevButton(
                  context,
                  'Corretor',
                  '/realtor',
                  Icons.business_outlined,
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDevButton(
                  context,
                  'Admin',
                  '/admin',
                  Icons.admin_panel_settings_outlined,
                  AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDevButton(
    BuildContext context,
    String label,
    String route,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).go(route);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: Text(
          'Sair',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
        ),
        onTap: () => _showLogoutDialog(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (type) {
      case SidebarType.navigation:
        return 'Menu';
      case SidebarType.filters:
        return 'Filtros';
      case SidebarType.combined:
        return 'Menu & Filtros';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

// Widget separado para o conteúdo dos filtros
class FilterSidebarContent extends StatefulWidget {
  final PropertyFilters filters;
  final Function(PropertyFilters) onFiltersChanged;
  final VoidCallback onClearFilters;
  final DrawerUserType? userType;

  const FilterSidebarContent({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    required this.onClearFilters,
    this.userType,
  });

  @override
  State<FilterSidebarContent> createState() => _FilterSidebarContentState();
}

class _FilterSidebarContentState extends State<FilterSidebarContent> {
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
  void didUpdateWidget(FilterSidebarContent oldWidget) {
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
    return Column(
      children: [
        // Filtros
        Expanded(
          child: SingleChildScrollView(
            padding: context.responsivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildPriceFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildLocationFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildPropertyTypeFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildCharacteristicsFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildTransactionTypeFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildPriceRangeFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildAdditionalFilters(),
                const SizedBox(height: AppSpacing.xl),
                _buildCondominiumAndIptuFilters(),
                if (widget.userType == DrawerUserType.realtor) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _buildRealtorSpecificFilters(),
                ],
                if (widget.userType == DrawerUserType.admin) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _buildAdminSpecificFilters(),
                ],
              ],
            ),
          ),
        ),
        
        // Botões aplicar e limpar
        Container(
          padding: context.responsivePadding,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Botão limpar filtros
              if (_currentFilters.hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(mobile: 12, tablet: 16, desktop: 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Limpar Filtros',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              // Botão aplicar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSpacing(mobile: 12, tablet: 16, desktop: 16),
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
            ],
          ),
        ),
      ],
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
            _currentFilters = _currentFilters.copyWith(minPrice: price);
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

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚡ Filtros Rápidos',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFilterChip('Até R\$ 200k', () {
              _currentFilters = _currentFilters.copyWith(maxPrice: 200000);
            }),
            _buildQuickFilterChip('Apartamentos', () {
              _currentFilters = _currentFilters.copyWith(
                propertyTypes: [PropertyType.apartment],
              );
            }),
            _buildQuickFilterChip('Para alugar', () {
              _currentFilters = _currentFilters.copyWith(
                transactionType: TransactionType.rent,
              );
            }),
            _buildQuickFilterChip('Com garagem', () {
              _currentFilters = _currentFilters.copyWith(minParkingSpaces: 1);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 Localização',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Cidade
        Text(
          'Cidade',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: 'Ex: São Paulo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            // Implementar lógica de filtro por cidade
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Bairro
        Text(
          'Bairro',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: 'Ex: Vila Madalena',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            // Implementar lógica de filtro por bairro
          },
        ),
      ],
    );
  }

  Widget _buildPropertyTypeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏠 Tipo de Imóvel',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        _buildFilterChip('Casa', PropertyType.house, 
            _currentFilters.propertyTypes.contains(PropertyType.house)),
        const SizedBox(height: AppSpacing.sm),
        _buildFilterChip('Apartamento', PropertyType.apartment, 
            _currentFilters.propertyTypes.contains(PropertyType.apartment)),
        const SizedBox(height: AppSpacing.sm),
        _buildFilterChip('Comercial', PropertyType.commercial, 
            _currentFilters.propertyTypes.contains(PropertyType.commercial)),
        const SizedBox(height: AppSpacing.sm),
        _buildFilterChip('Terreno', PropertyType.land, 
            _currentFilters.propertyTypes.contains(PropertyType.land)),
      ],
    );
  }

  Widget _buildCharacteristicsFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔧 Características',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Quartos
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quartos (mín)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 2',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final bedrooms = int.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(minBedrooms: bedrooms);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quartos (máx)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 4',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final bedrooms = int.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(maxBedrooms: bedrooms);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Banheiros
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Banheiros (mín)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final bathrooms = int.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(minBathrooms: bathrooms);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Banheiros (máx)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 3',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final bathrooms = int.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(maxBathrooms: bathrooms);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Vagas de garagem
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vagas (mín)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final parking = int.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(minParkingSpaces: parking);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vagas (máx)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 3',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final parking = int.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(maxParkingSpaces: parking);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Área
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Área (mín)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 50',
                      suffixText: 'm²',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final area = double.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(minArea: area);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Área (máx)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 150',
                      suffixText: 'm²',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      final area = double.tryParse(value);
                      _currentFilters = _currentFilters.copyWith(maxArea: area);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRealtorSpecificFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Filtros do Corretor',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        _buildSwitchTile(
          'Apenas em destaque',
          false, // Implementar lógica
          (value) {
            // Implementar lógica
          },
        ),
        _buildSwitchTile(
          'Apenas lançamentos',
          false, // Implementar lógica
          (value) {
            // Implementar lógica
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Text(
          'Ordenar por',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'date', child: Text('Data de cadastro')),
            DropdownMenuItem(value: 'price', child: Text('Preço')),
            DropdownMenuItem(value: 'status', child: Text('Status')),
            DropdownMenuItem(value: 'interest', child: Text('Interesse')),
          ],
          onChanged: (value) {
            // Implementar lógica de ordenação
          },
        ),
      ],
    );
  }

  Widget _buildAdminSpecificFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👨‍💼 Filtros Administrativos',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        Text(
          'Corretor',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: 'Selecionar corretor',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Todos os corretores')),
            DropdownMenuItem(value: 'realtor1', child: Text('Carlos Oliveira')),
            DropdownMenuItem(value: 'realtor2', child: Text('Ana Silva')),
            DropdownMenuItem(value: 'realtor3', child: Text('João Santos')),
          ],
          onChanged: (value) {
            // Implementar lógica de filtro por corretor
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Text(
          'Performance',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Todas as performances')),
            DropdownMenuItem(value: 'high', child: Text('Alta performance')),
            DropdownMenuItem(value: 'medium', child: Text('Média performance')),
            DropdownMenuItem(value: 'low', child: Text('Baixa performance')),
          ],
          onChanged: (value) {
            // Implementar lógica de filtro por performance
          },
        ),
      ],
    );
  }
}
