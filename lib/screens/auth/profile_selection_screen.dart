import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../models/user_model.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  UserType? _selectedUserType;

  void _selectUserType(UserType userType) {
    setState(() {
      _selectedUserType = userType;
    });
  }

  void _continue() {
    if (_selectedUserType == null) return;

    switch (_selectedUserType!) {
      case UserType.buyer:
        context.go('/user');
        break;
      case UserType.realtor:
        context.go('/realtor');
        break;
      case UserType.admin:
        context.go('/admin');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Selecione seu Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.verticalLG,
              
              // Title and Subtitle
              Text(
                'Como você deseja usar a plataforma?',
                style: AppTypography.h4,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSM,
              Text(
                'Escolha o perfil que melhor descreve você',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              AppSpacing.verticalXL,
              
              // Profile Options
              Expanded(
                child: ListView(
                  children: [
                    // Buyer Option
                    _ProfileCard(
                      title: 'Comprador',
                      subtitle: 'Procuro um imóvel para comprar',
                      icon: Icons.person_outline,
                      description: 'Navegue por imóveis, favorite seus preferidos, entre em contato com corretores e receba alertas.',
                      isSelected: _selectedUserType == UserType.buyer,
                      onTap: () => _selectUserType(UserType.buyer),
                    ),
                    
                    AppSpacing.verticalLG,
                    
                    // Realtor Option
                    _ProfileCard(
                      title: 'Corretor',
                      subtitle: 'Sou um corretor imobiliário',
                      icon: Icons.business_center_outlined,
                      description: 'Cadastre e gerencie seus imóveis, converse com clientes interessados e acompanhe suas vendas.',
                      isSelected: _selectedUserType == UserType.realtor,
                      onTap: () => _selectUserType(UserType.realtor),
                    ),
                    
                    AppSpacing.verticalLG,
                    
                    // Admin Option
                    _ProfileCard(
                      title: 'Administrador',
                      subtitle: 'Gerencio a plataforma',
                      icon: Icons.admin_panel_settings_outlined,
                      description: 'Gerencie todos os imóveis, corretores, visualize relatórios e administre a plataforma.',
                      isSelected: _selectedUserType == UserType.admin,
                      onTap: () => _selectUserType(UserType.admin),
                    ),
                  ],
                ),
              ),
              
              // Continue Button
              Container(
                padding: AppSpacing.paddingVerticalLG,
                child: ElevatedButton(
                  onPressed: _selectedUserType != null ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: AppTypography.buttonLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMD,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1 * 255),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary 
                    : AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusMD,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected 
                    ? AppColors.textOnPrimary 
                    : AppColors.textSecondary,
              ),
            ),
            
            AppSpacing.horizontalMD,
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h6.copyWith(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.verticalXS,
                  Text(
                    subtitle,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.verticalSM,
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.textOnPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
