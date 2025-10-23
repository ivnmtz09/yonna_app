import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yonna_app/services/api_service.dart';
import '../widgets/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Obtenemos la instancia Singleton
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    bool isAuthenticated = await _apiService.isLoggedIn();
    if (!mounted) return;
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/loading.gif',
              height: 180,
            ),
            const SizedBox(height: 24),
            const Text(
              'Yonna App',
              style: AppStyles.mainTitleStyle,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppColors.accentOrange,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
