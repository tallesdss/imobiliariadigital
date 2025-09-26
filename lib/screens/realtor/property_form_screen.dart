import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PropertyFormScreen extends StatelessWidget {
  final String? propertyId;

  const PropertyFormScreen({super.key, this.propertyId});

  @override
  Widget build(BuildContext context) {
    final isEdit = propertyId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Imóvel' : 'Cadastrar Imóvel'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_home, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(isEdit ? 'Editar Imóvel' : 'Cadastrar Imóvel', style: AppTypography.h4),
            const SizedBox(height: 8),
            Text('Em desenvolvimento...', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
