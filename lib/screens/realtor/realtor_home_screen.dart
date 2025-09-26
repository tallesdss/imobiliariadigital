import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class RealtorHomeScreen extends StatelessWidget {
  const RealtorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Corretor'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business_center, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Tela do Corretor', style: AppTypography.h4),
            const SizedBox(height: 8),
            Text('Em desenvolvimento...', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
