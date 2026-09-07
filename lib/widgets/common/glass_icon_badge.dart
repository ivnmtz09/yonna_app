import 'dart:ui';
import 'package:flutter/material.dart';

class GlassIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;
  final List<Color>? gradient;
  final VoidCallback? onTap;

  const GlassIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius = 14,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget badge = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: (gradient == null)
                ? color.withValues(alpha: isDark ? 0.15 : 0.12)
                : null,
            gradient: gradient != null
                ? LinearGradient(
                    colors: gradient!
                        .map((c) => c.withValues(alpha: isDark ? 0.35 : 0.25))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.20 : 0.10),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }
    return badge;
  }
}
