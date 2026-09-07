import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_styles.dart';
import 'glass_container.dart';

enum GlassButtonVariant {
  primary,
  secondary,
  glass,
  danger,
}

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final GlassButtonVariant variant;
  final bool? isPrimary;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = GlassButtonVariant.primary,
    this.isPrimary,
    this.width,
    this.height = 54,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final rRadius = borderRadius ?? BorderRadius.circular(16);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveVariant = isPrimary != null
        ? (isPrimary! ? GlassButtonVariant.primary : GlassButtonVariant.secondary)
        : variant;

    Color bgColor;
    Color textColor;
    Gradient? borderGradient;

    switch (effectiveVariant) {
      case GlassButtonVariant.primary:
        bgColor = AppColors.primaryOrange.withOpacity(isDark ? 0.88 : 0.92);
        textColor = Colors.white;
        borderGradient = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.1),
          ],
        );
        break;
      case GlassButtonVariant.secondary:
        bgColor = AppColors.primaryBlue.withOpacity(isDark ? 0.85 : 0.90);
        textColor = Colors.white;
        borderGradient = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.1),
          ],
        );
        break;
      case GlassButtonVariant.danger:
        bgColor = AppColors.errorRed.withOpacity(0.85);
        textColor = Colors.white;
        borderGradient = null;
        break;
      case GlassButtonVariant.glass:
        bgColor = isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.black.withOpacity(0.04);
        textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        borderGradient = AppTheme.glass(context).borderGradient;
        break;
    }

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: GlassContainer(
        width: width,
        height: height,
        borderRadius: rRadius,
        backgroundColor: bgColor,
        borderGradient: borderGradient,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: rRadius,
            splashColor: Colors.white.withOpacity(0.15),
            onTap: (onPressed != null && !isLoading)
                ? () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  }
                : null,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
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
