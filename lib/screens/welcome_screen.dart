import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_icons.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_button.dart';
import '../widgets/glass/glass_container.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Botón rápido de cambio de tema en la esquina superior
              Positioned(
                top: 12,
                right: 16,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    themeProvider.cycleThemeMode();
                  },
                  borderRadius: BorderRadius.circular(21),
                  child: GlassContainer(
                    width: 42,
                    height: 42,
                    borderRadius: BorderRadius.circular(21),
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.85),
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Icon(
                        themeProvider.themeIcon,
                        size: 19,
                        color: isDark ? const Color(0xFFF1F5F9) : AppColors.darkText,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo o Mascota en contenedor de cristal
                    GlassContainer(
                      width: 170,
                      height: 170,
                      borderRadius: BorderRadius.circular(85),
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.80),
                      borderGradient: LinearGradient(
                        colors: [
                          AppColors.primaryOrange.withValues(alpha: 0.5),
                          AppColors.primaryBlue.withValues(alpha: 0.2),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/welcome.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Título principal
                    Text(
                      'Antüshi pia',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Subtítulo Wayuu
                    Text(
                      '(Bienvenido a Yonna)',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Descripción
                    Text(
                      'Aprende, revitaliza y domina el idioma Wayuunaiki\ncon lecciones interactivas gamificadas.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : AppColors.lightText,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 3),

                    // Botones de acción con GlassButton
                    GlassButton(
                      text: 'INICIAR SESIÓN',
                      icon: AppIcons.profile,
                      isPrimary: true,
                      height: 52,
                      width: double.infinity,
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                    const SizedBox(height: 12),

                    GlassButton(
                      text: 'CREAR CUENTA',
                      icon: Icons.person_add_rounded,
                      isPrimary: false,
                      height: 52,
                      width: double.infinity,
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
