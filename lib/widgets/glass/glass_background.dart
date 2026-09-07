import 'package:flutter/material.dart';
import '../../widgets/app_styles.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Color base de fondo
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF0A0E17) : const Color(0xFFF8FAFC),
          ),
        ),

        // Luz difusa 1: Resplandor cálido Yonna (Naranja)
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryOrange.withOpacity(isDark ? 0.22 : 0.12),
                  AppColors.primaryOrange.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Luz difusa 2: Resplandor Wayuu (Turquesa / Jade)
        Positioned(
          bottom: 120,
          left: -100,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(isDark ? 0.18 : 0.10),
                  AppColors.primaryBlue.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Luz difusa 3: Resplandor sutil intermedio
        Positioned(
          top: 350,
          right: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? const Color(0xFF38BDF8) : const Color(0xFFCBD5E1))
                      .withOpacity(isDark ? 0.12 : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Contenido por encima de las luces ambientales
        child,
      ],
    );
  }
}
