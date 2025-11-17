import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Esperar un mínimo de 3 segundos para mostrar el splash
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final provider = context.read<AppProvider>();

    try {
      await provider.initializeApp();

      if (!mounted) return;

      if (provider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      print('Error initializing app: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Contenedor para el GIF con bordes redondeados
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.backgroundWhite.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/loading.gif',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.school,
                        size: 60,
                        color: AppColors.backgroundWhite.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppStyles.spacingXL),
            // Nombre de la app
            Text(
              'Yonna APP',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.whiteText,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              'Aprende Wayuunaiki',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.whiteText.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppStyles.spacingXL),
            // Indicador de carga
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.whiteText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}