import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

enum DrawerUserType { realtor, admin }

class CustomDrawer extends StatelessWidget {
  final DrawerUserType userType;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final Function(String) onNavigate;

  const CustomDrawer({
    super.key,
    required this.userType,
    required this.userName,
    required this.userEmail,
    required this.onNavigate,
    this.userAvatar,
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
                ..._buildMenuItems(),
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
      height: 180,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
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
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    if (userType == DrawerUserType.realtor) {
      return [
        _buildMenuItem(Icons.dashboard_outlined, 'Dashboard', '/realtor-home'),
        _buildMenuItem(
          Icons.business_outlined,
          'Meus Imóveis',
          '/realtor-properties',
        ),
        _buildMenuItem(
          Icons.add_business_outlined,
          'Cadastrar Imóvel',
          '/property-form',
        ),
        _buildMenuItem(Icons.person_outline, 'Meu Perfil', '/realtor-profile'),
        _buildMenuItem(Icons.chat_bubble_outline, 'Mensagens', '/realtor-chat'),
        _buildMenuItem(
          Icons.analytics_outlined,
          'Relatórios',
          '/realtor-reports',
        ),
      ];
    } else {
      return [
        _buildMenuItem(
          Icons.dashboard_outlined,
          'Dashboard',
          '/admin-dashboard',
        ),
        _buildMenuItem(
          Icons.home_work_outlined,
          'Todos os Imóveis',
          '/admin-home',
        ),
        _buildMenuItem(
          Icons.people_outline,
          'Gestão de Corretores',
          '/admin-realtors',
        ),
        _buildMenuItem(
          Icons.add_business_outlined,
          'Cadastrar Imóvel',
          '/property-form',
        ),
        _buildMenuItem(Icons.chat_bubble_outline, 'Mensagens', '/admin-chat'),
        _buildMenuItem(
          Icons.settings_outlined,
          'Configurações',
          '/admin-settings',
        ),
      ];
    }
  }

  Widget _buildMenuItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      onTap: () => onNavigate(route),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.error),
      title: Text(
        'Sair',
        style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
      ),
      onTap: () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
