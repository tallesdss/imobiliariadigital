import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_breakpoints.dart';
import '../../models/filter_model.dart';
import 'fixed_sidebar.dart';
import 'custom_drawer.dart';

/// Sidebar responsiva que se adapta ao tamanho da tela
class ResponsiveSidebar extends StatelessWidget {
  final SidebarType type;
  final DrawerUserType? userType;
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

  const ResponsiveSidebar({
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
    // Em mobile, não mostrar sidebar lateral
    if (context.isMobile) {
      return const SizedBox.shrink();
    }
    
    // Em desktop/tablet, usar sidebar fixa
    return _buildDesktopSidebar(context);
  }


  Widget _buildDesktopSidebar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isVisible ? context.sidebarWidth : 0,
      child: isVisible
          ? Container(
              width: context.sidebarWidth,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  right: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
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
            )
          : _buildCollapsedSidebar(context),
    );
  }

  Widget _buildCollapsedSidebar(BuildContext context) {
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
                const SizedBox(height: 8),
                Text(
                  type == SidebarType.filters ? 'Filtros' : 'Menu',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
          
          // Filtros
          if (filters != null && onFiltersChanged != null)
            FilterSidebarContent(
              filters: filters!,
              onFiltersChanged: onFiltersChanged!,
              onClearFilters: onClearFilters ?? () {},
              userType: userType,
            ),
          
          const Divider(),
          _buildDevelopmentSection(context),
          const Divider(),
          _buildLogoutItem(context),
        ],
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

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            backgroundImage: userAvatar != null ? NetworkImage(userAvatar!) : null,
            child: userAvatar == null
                ? Text(
                    userName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? 'Usuário',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail ?? '',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (userCreci != null)
                  Text(
                    'CRECI: $userCreci',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem(
        context,
        icon: Icons.home,
        title: 'Início',
        route: '/user',
        isActive: currentRoute == '/user',
      ),
      _buildMenuItem(
        context,
        icon: Icons.search,
        title: 'Buscar',
        route: '/user/search',
        isActive: currentRoute == '/user/search',
      ),
      _buildMenuItem(
        context,
        icon: Icons.favorite,
        title: 'Favoritos',
        route: '/user/favorites',
        isActive: currentRoute == '/user/favorites',
      ),
      _buildMenuItem(
        context,
        icon: Icons.notifications,
        title: 'Alertas',
        route: '/user/alerts',
        isActive: currentRoute == '/user/alerts',
      ),
      _buildMenuItem(
        context,
        icon: Icons.chat,
        title: 'Chat',
        route: '/user/chat',
        isActive: currentRoute == '/user/chat',
      ),
    ];
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
      title:                 Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
      selected: isActive,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      onTap: () {
        Navigator.of(context).pop(); // Fechar drawer se estiver em mobile
        // Navegação será tratada pelo roteador
      },
    );
  }

  Widget _buildDevelopmentSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings, color: AppColors.textSecondary),
          title: Text(
            'Configurações',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            // Navegar para configurações
          },
        ),
        ListTile(
          leading: const Icon(Icons.help, color: AppColors.textSecondary),
          title: Text(
            'Ajuda',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            // Navegar para ajuda
          },
        ),
      ],
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: Text(
        'Sair',
        style: AppTypography.bodyMedium.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        // Implementar logout
      },
    );
  }
}
