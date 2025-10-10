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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Limpar os campos do formulário
      _emailController.clear();
      _passwordController.clear();
      
      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Aguardar um momento para mostrar a mensagem
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Navegar baseado no tipo de usuário
      final user = authService.currentUser;
      if (user != null) {
        switch (user.type) {
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
    } else {
      // Mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? 'Erro no login'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      // Limpar os campos do formulário
      _emailController.clear();
      _passwordController.clear();
      
      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login com Google realizado com sucesso!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Aguardar um momento para mostrar a mensagem
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Navegar baseado no tipo de usuário
      final user = authService.currentUser;
      if (user != null) {
        switch (user.type) {
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

  void _handleRegister() {
    context.push('/register');
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
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return CustomButton(
                              text: 'Entrar',
                              onPressed: authService.isLoading ? null : _handleLogin,
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
