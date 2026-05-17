// Bouton principal réutilisable OZELSERVICES Livreur
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Variantes visuelles du bouton OZEL
enum OzelButtonVariant { primary, secondary, danger }

/// Bouton principal de l'application avec états loading et disabled
class OzelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final OzelButtonVariant variant;
  final double? width;
  final double height;
  final IconData? icon;

  const OzelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = OzelButtonVariant.primary,
    this.width,
    this.height = 50,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? colors.background.withValues(alpha: 0.5)
              : colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: colors.background.withValues(alpha: 0.4),
          disabledForegroundColor: colors.foreground.withValues(alpha: 0.6),
          elevation: isDisabled ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: variant == OzelButtonVariant.secondary
                ? const BorderSide(color: AppColors.kPrimaryOrange, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case OzelButtonVariant.primary:
        return _ButtonColors(
          background: AppColors.kPrimaryOrange,
          foreground: AppColors.kWhite,
        );
      case OzelButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.kWhite,
          foreground: AppColors.kPrimaryOrange,
        );
      case OzelButtonVariant.danger:
        return _ButtonColors(
          background: AppColors.kRed,
          foreground: AppColors.kWhite,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  const _ButtonColors({required this.background, required this.foreground});
}
