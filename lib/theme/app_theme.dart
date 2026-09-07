import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';

class GlassThemeData {
  final double blurSigma;
  final Color cardBackground;
  final Color cardBorder;
  final LinearGradient borderGradient;
  final Color floatingNavBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color scaffoldBackground;
  final List<BoxShadow> glassShadow;

  const GlassThemeData({
    required this.blurSigma,
    required this.cardBackground,
    required this.cardBorder,
    required this.borderGradient,
    required this.floatingNavBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.scaffoldBackground,
    required this.glassShadow,
  });
}

class AppTheme {
  // Configuración de Glassmorphism para Modo Oscuro (Noche Guajira)
  static final GlassThemeData darkGlass = GlassThemeData(
    blurSigma: 16.0,
    cardBackground: const Color(0xFF131A2A).withOpacity(0.55),
    cardBorder: Colors.white.withOpacity(0.12),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.25),
        Colors.white.withOpacity(0.04),
      ],
    ),
    floatingNavBackground: const Color(0xFF0F172A).withOpacity(0.78),
    textPrimary: const Color(0xFFF8FAFC),
    textSecondary: const Color(0xFF94A3B8),
    scaffoldBackground: const Color(0xFF0A0E17),
    glassShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // Configuración de Glassmorphism para Modo Claro (Día Soleado)
  static final GlassThemeData lightGlass = GlassThemeData(
    blurSigma: 14.0,
    cardBackground: Colors.white.withOpacity(0.72),
    cardBorder: Colors.white.withOpacity(0.85),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.95),
        Colors.white.withOpacity(0.35),
      ],
    ),
    floatingNavBackground: Colors.white.withOpacity(0.82),
    textPrimary: const Color(0xFF0F172A),
    textSecondary: const Color(0xFF64748B),
    scaffoldBackground: const Color(0xFFF8FAFC),
    glassShadow: [
      BoxShadow(
        color: const Color(0xFF64748B).withOpacity(0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Helper para obtener la configuración de cristal activa según el contexto
  static GlassThemeData glass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkGlass : lightGlass;
  }

  // Tema Claro de Flutter
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryOrange,
        brightness: Brightness.light,
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryBlue,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  // Tema Oscuro de Flutter
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0E17),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryOrange,
        brightness: Brightness.dark,
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryBlue,
        surface: const Color(0xFF131A2A),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF8FAFC),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
      ),
    );
  }
}
