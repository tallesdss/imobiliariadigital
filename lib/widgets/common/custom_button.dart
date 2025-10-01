import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

enum ButtonType { filled, outlined, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    EdgeInsets padding;
    TextStyle textStyle;
    double height;

    switch (size) {
      case ButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        textStyle = AppTypography.buttonSmall;
        height = 36;
        break;
      case ButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        textStyle = AppTypography.buttonMedium;
        height = 44;
        break;
      case ButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        textStyle = AppTypography.buttonLarge;
        height = 52;
        break;
    }

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.filled
                    ? AppColors.textOnPrimary
                    : AppColors.primary,
              ),
            ),
          ),
          AppSpacing.horizontalSM,
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          AppSpacing.horizontalSM,
        ],
        Flexible(
          child: Text(
            text,
            style: textStyle.copyWith(
              color:
                  textColor ??
                  (type == ButtonType.filled
                      ? AppColors.textOnPrimary
                      : AppColors.primary),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    Widget button;

    switch (type) {
      case ButtonType.filled:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.textHint,
            disabledForegroundColor: AppColors.textOnPrimary,
            elevation: isDisabled ? 0 : 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.3 * 255),
            padding: padding,
            minimumSize: Size(width ?? 0, height),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            disabledForegroundColor: AppColors.textHint,
            side: BorderSide(
              color: isDisabled
                  ? AppColors.textHint
                  : (backgroundColor ?? AppColors.primary),
              width: 1.5,
            ),
            padding: padding,
            minimumSize: Size(width ?? 0, height),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            disabledForegroundColor: AppColors.textHint,
            padding: padding,
            minimumSize: Size(width ?? 0, height),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
          ),
          child: buttonChild,
        );
        break;
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}
