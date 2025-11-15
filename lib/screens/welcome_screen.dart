import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.blueGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: AppStyles.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo o imagen
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.whiteText.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/welcome.png',
                    height: 140,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXL),

                // Título principal
                Text(
                  'Antüshi pia',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.whiteText,
                    fontSize: 36,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppStyles.spacingS),

                // Subtítulo
                Text(
                  '(Bienvenido)',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.whiteText.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppStyles.spacingL),

                // Descripción
                Text(
                  'Aprende, juega y crece con nosotros\nen el idioma Wayuunaiki',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.whiteText.withOpacity(0.85),
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 3),

                // Botones
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.whiteText,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppStyles.standardBorderRadius,
                      ),
                      elevation: 4,
                      textStyle: AppTextStyles.button,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('INICIAR SESIÓN'),
                  ),
                ),
                const SizedBox(height: AppStyles.spacingM),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.whiteText,
                      side: const BorderSide(
                        color: AppColors.whiteText,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppStyles.standardBorderRadius,
                      ),
                      textStyle: AppTextStyles.button,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text('REGISTRARSE'),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
