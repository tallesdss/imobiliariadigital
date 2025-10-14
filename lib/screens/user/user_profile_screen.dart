import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Aguardar um frame para garantir que o AuthService esteja inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    } else {
      // Se não há usuário, tentar recarregar os dados
      _refreshUserData();
    }
  }

  Future<void> _refreshUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.initialize();
    if (mounted) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );

    if (mounted) {
      if (success) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error ?? 'Erro ao atualizar perfil'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Editar'),
            ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          
          if (authService.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  AppSpacing.verticalMD,
                  Text(
                    'Carregando perfil...',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            );
          }
          
          if (authService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  AppSpacing.verticalMD,
                  Text(
                    'Erro ao carregar perfil',
                    style: AppTypography.h3,
                  ),
                  AppSpacing.verticalSM,
                  Text(
                    authService.error!,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalMD,
                  CustomButton(
                    text: 'Tentar Novamente',
                    onPressed: () {
                      authService.initialize();
                    },
                  ),
                ],
              ),
            );
          }
          
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  AppSpacing.verticalMD,
                  Text(
                    'Usuário não encontrado',
                    style: AppTypography.h3,
                  ),
                  AppSpacing.verticalSM,
                  Text(
                    'Não foi possível carregar os dados do seu perfil. Verifique se você está logado corretamente.',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalMD,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: 'Tentar Novamente',
                        onPressed: () {
                          _refreshUserData();
                        },
                        type: ButtonType.outlined,
                      ),
                      AppSpacing.horizontalMD,
                      CustomButton(
                        text: 'Fazer Login',
                        onPressed: () {
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshUserData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.paddingLG,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Photo
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1 * 255),
                        child: user.photo != null
                            ? ClipOval(
                                child: Image.network(
                                  user.photo!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.primary,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: AppColors.textOnPrimary,
                                size: 20,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Funcionalidade de upload será implementada em breve'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                AppSpacing.verticalLG,

                // User Type Badge
                Center(
                  child: Container(
                    padding: AppSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: _getUserTypeColor(user.type).withValues(alpha: 0.1 * 255),
                      borderRadius: AppSpacing.borderRadiusSM,
                      border: Border.all(
                        color: _getUserTypeColor(user.type).withValues(alpha: 0.3 * 255),
                      ),
                    ),
                    child: Text(
                      _getUserTypeLabel(user.type),
                      style: AppTypography.labelMedium.copyWith(
                        color: _getUserTypeColor(user.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                AppSpacing.verticalXXL,

                // Profile Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nome',
                        enabled: _isEditing,
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite seu nome';
                          }
                          if (value.length < 2) {
                            return 'Nome deve ter pelo menos 2 caracteres';
                          }
                          return null;
                        },
                      ),

                      AppSpacing.verticalMD,

                      CustomTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        enabled: false, // Email não pode ser alterado
                        prefixIcon: Icons.email_outlined,
                      ),

                      AppSpacing.verticalMD,

                      CustomTextField(
                        controller: _phoneController,
                        label: 'Telefone',
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),

                      AppSpacing.verticalLG,

                      // Action Buttons
                      if (_isEditing) ...[
                        CustomButton(
                          text: 'Salvar',
                          onPressed: authService.isLoading ? null : _handleSave,
                          isLoading: authService.isLoading,
                        ),
                        AppSpacing.verticalMD,
                        CustomButton(
                          text: 'Cancelar',
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                            });
                            _loadUserData(); // Restore original data
                          },
                          type: ButtonType.outlined,
                        ),
                      ] else ...[
                        CustomButton(
                          text: 'Sair da Conta',
                          onPressed: _handleLogout,
                          type: ButtonType.outlined,
                        ),
                      ],
                    ],
                  ),
                ),

                AppSpacing.verticalXXL,

                // Account Info
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1 * 255),
                    borderRadius: AppSpacing.borderRadiusSM,
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3 * 255),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.info,
                          ),
                          AppSpacing.horizontalSM,
                          Text(
                            'Informações da Conta',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSM,
                      Text(
                        'Conta criada em: ${_formatDate(user.createdAt)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                      AppSpacing.verticalXS,
                      Text(
                        'Status: ${user.isActive ? "Ativa" : "Inativa"}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Color _getUserTypeColor(UserType type) {
    switch (type) {
      case UserType.buyer:
        return AppColors.primary;
      case UserType.realtor:
        return AppColors.warning;
      case UserType.admin:
        return AppColors.error;
    }
  }

  String _getUserTypeLabel(UserType type) {
    switch (type) {
      case UserType.buyer:
        return 'Comprador';
      case UserType.realtor:
        return 'Corretor';
      case UserType.admin:
        return 'Administrador';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
