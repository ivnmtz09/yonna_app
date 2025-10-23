import 'package:flutter/material.dart';

// Paleta de colores oficial de Yonna App
class AppColors {
  static const Color primaryGreen = Color(0xFF60AB90);
  static const Color accentOrange = Color(0xFFFF8025);
  static const Color backgroundWhite = Colors.white;
  static const Color darkText = Color(0xFF2C3E50);
}

// Estilos de borde y tipografía comunes
class AppStyles {
  static const BorderRadius standardBorderRadius =
      BorderRadius.all(Radius.circular(12));

  static const TextStyle mainTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.accentOrange,
  );

  static const TextStyle drawerItemStyle = TextStyle(
    fontSize: 16,
    color: AppColors.darkText,
    fontWeight: FontWeight.w600,
  );
}
