import 'package:flutter/material.dart';

/// Paleta de colores coherente con el frontend web
class AppColors {
  // Colores principales
  static const Color primaryOrange = Color(0xFFFF914D); // Naranja principal
  static const Color primaryBlue = Color(0xFF60AB90); // Azul yonna
  static const Color accentGreen =
      Color.fromARGB(255, 34, 179, 126); // Verde Wayuu (mantener)

  // Colores de fondo
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF5F5F5);

  // Colores de texto
  static const Color darkText = Color(0xFF222222);
  static const Color lightText = Color(0xFF666666);
  static const Color whiteText = Color(0xFFFFFFFF);

  // Colores de estado
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color infoBlue = Color(0xFF2196F3);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, Color(0xFFFF7A29)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, Color.fromARGB(255, 0, 128, 107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Estilos de texto comunes
class AppTextStyles {
  // Títulos
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  // Cuerpo
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.lightText,
  );

  // Botones
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Especiales
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.lightText,
    fontStyle: FontStyle.italic,
  );
}

/// Estilos de componentes
class AppStyles {
  // Bordes
  static const BorderRadius standardBorderRadius =
      BorderRadius.all(Radius.circular(12));
  static const BorderRadius smallBorderRadius =
      BorderRadius.all(Radius.circular(8));
  static const BorderRadius largeBorderRadius =
      BorderRadius.all(Radius.circular(16));

  // Sombras
  static final List<BoxShadow> standardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> largeShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);

  // Espaciado
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;

  // Decoraciones de botones
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.whiteText,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: standardBorderRadius),
    elevation: 2,
    textStyle: AppTextStyles.button,
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.backgroundWhite,
    foregroundColor: AppColors.primaryOrange,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: standardBorderRadius,
      side: const BorderSide(color: AppColors.primaryOrange, width: 2),
    ),
    elevation: 0,
    textStyle: AppTextStyles.button,
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: standardBorderRadius),
    side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
    textStyle: AppTextStyles.button,
  );

  // Decoración de inputs
  static InputDecoration inputDecoration({
    required String labelText,
    IconData? icon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppColors.primaryBlue),
      hintStyle: TextStyle(color: AppColors.lightText.withOpacity(0.6)),
      prefixIcon:
          icon != null ? Icon(icon, color: AppColors.primaryOrange) : null,
      filled: true,
      fillColor: AppColors.backgroundWhite,
      enabledBorder: OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: AppColors.errorRed, width: 2),
      ),
    );
  }

  // Decoración de cards
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.backgroundWhite,
    borderRadius: standardBorderRadius,
    boxShadow: standardShadow,
  );
}

/// Utilidades de animación
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
}
