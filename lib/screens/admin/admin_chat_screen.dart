import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AdminChatScreen extends StatelessWidget {
  const AdminChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Chat do Administrador', style: AppTypography.h4),
            const SizedBox(height: 8),
            Text('Em desenvolvimento...', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
