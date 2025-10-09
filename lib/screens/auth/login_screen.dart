import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      context.go('/profile-selection');
    }
  }

  void _handleRegister() {
    // In a real app, this would navigate to registration screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de cadastro será implementada em breve'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  if (!isTablet) AppSpacing.verticalXXL,

                  // Logo and Title
                  Column(
                    children: [
                      Container(
                        width: isTablet ? 100 : 120,
                        height: isTablet ? 100 : 120,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppSpacing.borderRadiusXL,
                        ),
                        child: Icon(
                          Icons.home_work,
                          size: isTablet ? 50 : 60,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      AppSpacing.verticalLG,
                      Text(
                        'Imobiliária Digital',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.primary,
                          fontSize: isTablet ? 28 : 32,
                        ),
                      ),
                      AppSpacing.verticalSM,
                      Text(
                        'Encontre seu imóvel ideal',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isTablet ? 16 : 18,
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.verticalXXL,

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Entrar',
                          style: AppTypography.h4.copyWith(
                            fontSize: isTablet ? 22 : 24,
                          ),
                        ),
                        AppSpacing.verticalLG,

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

                        AppSpacing.verticalSM,

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Funcionalidade será implementada em breve',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Esqueci minha senha',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        AppSpacing.verticalLG,

                        // Login Button
                        CustomButton(
                          text: 'Entrar',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          size: ButtonSize.large,
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

                        // Register Button
                        CustomButton(
                          text: 'Criar conta',
                          onPressed: _handleRegister,
                          type: ButtonType.outlined,
                          size: ButtonSize.large,
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.verticalXXL,

                  // Demo Info
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
                              'Demo - Apenas Frontend',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSM,
                        Text(
                          'Este é um projeto de demonstração. Qualquer e-mail/senha funcionará para acessar o sistema.',
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
          ),
        ),
      ),
    );
  }
}
