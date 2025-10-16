import 'package:flutter/material.dart';
import 'package:yonna_app/screens/login_screen.dart';
import 'package:yonna_app/screens/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E6),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 20,
              right: 20,
              child: Image.asset('assets/images/welcome.png', height: 120),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/yonna.png', height: 120),
                    const SizedBox(height: 24),
                    const Text(
                      "Aprende Wayuunaiki jugando",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8025),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Conecta la cultura Wayuu con la tecnología.\n"
                      "Aprende, escucha y vive el idioma ancestral.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF444444)),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8025),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Acceder",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Color(0xFFFF8025)),
                      ),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(
                          color: Color(0xFFFF8025),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "El inicio con Google estará disponible próximamente.",
                      style: TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
