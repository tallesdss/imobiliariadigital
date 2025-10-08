import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

enum DrawerUserType { realtor, admin }

class CustomDrawer extends StatelessWidget {
  final DrawerUserType userType;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final String? userCreci; // Para corretores
  final String currentRoute;

  const CustomDrawer({
    super.key,
    required this.userType,
    required this.userName,
    required this.userEmail,
    required this.currentRoute,
    this.userAvatar,
    this.userCreci,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._buildMenuItems(context),
                const Divider(),
                _buildLogoutItem(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: userAvatar != null
                        ? NetworkImage(userAvatar!)
                        : null,
                    child: userAvatar == null
                        ? Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
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
                userName,
                style: AppTypography.h6.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
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
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
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
          Navigator.pop(context);
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
