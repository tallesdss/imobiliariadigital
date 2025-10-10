import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );

    if (mounted) {
      if (success) {
        // Navegar para seleção de perfil
        context.go('/profile-selection');
      } else {
        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error ?? 'Erro no registro'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signInWithGoogle();

    if (mounted) {
      if (success) {
        // Navegar para seleção de perfil
        context.go('/profile-selection');
      } else {
        // Mostrar erro apenas se não foi cancelado pelo usuário
        if (authService.error != null && !authService.error!.contains('cancelado')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authService.error ?? 'Erro no login com Google'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 500 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Column(
                    children: [
                      Container(
                        width: isTablet ? 80 : 100,
                        height: isTablet ? 80 : 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppSpacing.borderRadiusXL,
                        ),
                        child: Icon(
                          Icons.home_work,
                          size: isTablet ? 40 : 50,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      AppSpacing.verticalLG,
                      Text(
                        'Criar Conta',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.primary,
                          fontSize: isTablet ? 28 : 32,
                        ),
                      ),
                      AppSpacing.verticalSM,
                      Text(
                        'Preencha os dados para criar sua conta',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isTablet ? 16 : 18,
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.verticalXXL,

                  // Register Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          label: 'Nome completo',
                          hintText: 'Digite seu nome completo',
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
                          hintText: 'Digite seu e-mail',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu e-mail';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Por favor, digite um e-mail válido';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.verticalMD,

                        CustomTextField(
                          controller: _phoneController,
                          label: 'Telefone (opcional)',
                          hintText: '(11) 99999-9999',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),

                        AppSpacing.verticalMD,

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          hintText: 'Digite sua senha',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite sua senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.verticalMD,

                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar senha',
                          hintText: 'Digite sua senha novamente',
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme sua senha';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.verticalLG,

                        // Register Button
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return CustomButton(
                              text: 'Criar conta',
                              onPressed: authService.isLoading ? null : _handleRegister,
                              isLoading: authService.isLoading,
                              size: ButtonSize.large,
                            );
                          },
                        ),

                        AppSpacing.verticalLG,

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: AppSpacing.paddingHorizontalMD,
                              child: Text(
                                'ou',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        AppSpacing.verticalLG,

                        // Google Sign-In Button
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return CustomButton(
                              text: 'Continuar com Google',
                              onPressed: authService.isLoading ? null : _handleGoogleSignIn,
                              type: ButtonType.outlined,
                              size: ButtonSize.large,
                               icon: Icons.login,
                            );
                          },
                        ),

                        AppSpacing.verticalLG,

                        // Login Button
                        CustomButton(
                          text: 'Já tenho uma conta',
                          onPressed: () => context.pop(),
                          type: ButtonType.outlined,
                          size: ButtonSize.large,
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.verticalXXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
