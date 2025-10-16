import 'package:flutter/material.dart';
import 'package:yonna_app/services/auth_service.dart';
import 'package:yonna_app/screens/home_screen.dart';
import 'package:yonna_app/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? HomeScreen() : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 230),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/yonna.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              "Yonna App",
              style: TextStyle(
                color: Color.fromARGB(255, 255, 123, 0),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 255, 123, 0),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
