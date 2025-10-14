import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../models/filter_model.dart';
import 'fixed_sidebar.dart';
import 'custom_drawer.dart';

/// Helper para gerenciar drawer mobile
class MobileDrawerHelper {
  /// Cria um drawer para mobile com filtros
  static Widget buildFiltersDrawer({
    required BuildContext context,
    required PropertyFilters? filters,
    required Function(PropertyFilters)? onFiltersChanged,
    VoidCallback? onClearFilters,
    DrawerUserType? userType,
  }) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          _buildDrawerHeader(context, 'Filtros'),
          Expanded(
            child: filters != null && onFiltersChanged != null
                ? FilterSidebarContent(
                    filters: filters,
                    onFiltersChanged: onFiltersChanged,
                    onClearFilters: onClearFilters ?? () {},
                    userType: userType,
                  )
                : const Center(
                    child: Text('Filtros não disponíveis'),
                  ),
          ),
        ],
      ),
    );
  }

  /// Cria um drawer para mobile com navegação
  static Widget buildNavigationDrawer({
    required BuildContext context,
    required String currentRoute,
    DrawerUserType? userType,
    String? userName,
    String? userEmail,
    String? userAvatar,
    String? userCreci,
  }) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          _buildDrawerHeader(context, 'Menu'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header do usuário
                  if (userName != null && userEmail != null)
                    _buildUserHeader(context, userName, userEmail, userAvatar, userCreci),
                  
                  // Menu items
                  ..._buildMenuItems(context, currentRoute, userType),
                  const Divider(),
                  _buildDevelopmentSection(context),
                  const Divider(),
                  _buildLogoutItem(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDrawerHeader(BuildContext context, String title) {
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: AppColors.textOnPrimary,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTypography.h6.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildUserHeader(
    BuildContext context,
    String userName,
    String userEmail,
    String? userAvatar,
    String? userCreci,
  ) {
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
            backgroundImage: userAvatar != null ? NetworkImage(userAvatar) : null,
            child: userAvatar == null
                ? Text(
                    userName.substring(0, 1).toUpperCase(),
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
                  userName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
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

  static List<Widget> _buildMenuItems(
    BuildContext context,
    String currentRoute,
    DrawerUserType? userType,
  ) {
    List<Map<String, dynamic>> menuItems = [];

    switch (userType) {
      case DrawerUserType.user:
        menuItems = [
          {'icon': Icons.home, 'title': 'Início', 'route': '/user'},
          {'icon': Icons.search, 'title': 'Buscar', 'route': '/user/search'},
          {'icon': Icons.favorite, 'title': 'Favoritos', 'route': '/user/favorites'},
          {'icon': Icons.notifications, 'title': 'Alertas', 'route': '/user/alerts'},
          {'icon': Icons.chat, 'title': 'Chat', 'route': '/user/chat'},
        ];
        break;
      case DrawerUserType.realtor:
        menuItems = [
          {'icon': Icons.home, 'title': 'Início', 'route': '/realtor'},
          {'icon': Icons.add, 'title': 'Adicionar Imóvel', 'route': '/realtor/add-property'},
          {'icon': Icons.list, 'title': 'Meus Imóveis', 'route': '/realtor/properties'},
          {'icon': Icons.chat, 'title': 'Conversas', 'route': '/realtor/chat'},
          {'icon': Icons.person, 'title': 'Perfil', 'route': '/realtor/profile'},
        ];
        break;
      case DrawerUserType.admin:
        menuItems = [
          {'icon': Icons.dashboard, 'title': 'Dashboard', 'route': '/admin'},
          {'icon': Icons.home, 'title': 'Imóveis', 'route': '/admin/properties'},
          {'icon': Icons.people, 'title': 'Corretores', 'route': '/admin/realtors'},
          {'icon': Icons.chat, 'title': 'Chat', 'route': '/admin/chat'},
          {'icon': Icons.assessment, 'title': 'Relatórios', 'route': '/admin/reports'},
        ];
        break;
      default:
        menuItems = [
          {'icon': Icons.home, 'title': 'Início', 'route': '/user'},
        ];
    }

    return menuItems.map((item) {
      final isActive = currentRoute == item['route'];
      return ListTile(
        leading: Icon(
          item['icon'],
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          item['title'],
          style: AppTypography.bodyMedium.copyWith(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        onTap: () {
          Navigator.of(context).pop();
          // Navegação será tratada pelo roteador
        },
      );
    }).toList();
  }

  static Widget _buildDevelopmentSection(BuildContext context) {
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

  static Widget _buildLogoutItem(BuildContext context) {
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

