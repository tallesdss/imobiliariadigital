import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/property_model.dart';

class StatusBadge extends StatelessWidget {
  final PropertyStatus status;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: fontSize ?? 12,
            color: config.textColor,
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: AppTypography.labelSmall.copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return _StatusConfig(
          label: 'Ativo',
          icon: Icons.check_circle,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          borderColor: AppColors.success.withValues(alpha: 0.3),
          textColor: AppColors.success,
        );
      case PropertyStatus.sold:
        return _StatusConfig(
          label: 'Vendido',
          icon: Icons.verified,
          backgroundColor: AppColors.accent.withValues(alpha: 0.1),
          borderColor: AppColors.accent.withValues(alpha: 0.3),
          textColor: AppColors.accent,
        );
      case PropertyStatus.archived:
        return _StatusConfig(
          label: 'Arquivado',
          icon: Icons.archive,
          backgroundColor: AppColors.textHint.withValues(alpha: 0.1),
          borderColor: AppColors.textHint.withValues(alpha: 0.3),
          textColor: AppColors.textHint,
        );
      case PropertyStatus.suspended:
        return _StatusConfig(
          label: 'Suspenso',
          icon: Icons.pause_circle,
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          textColor: AppColors.warning,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

// Widget para badge simples com texto apenas
class SimpleBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const SimpleBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: textColor ?? AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
