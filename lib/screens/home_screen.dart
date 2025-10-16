import 'package:flutter/material.dart';
import 'package:yonna_app/services/auth_service.dart';
import 'package:yonna_app/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 230),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8025),
        title: const Text("Inicio - Yonna App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/yonna.png', height: 100),
              const SizedBox(height: 24),
              const Text(
                "¡Bienvenido a Yonna App!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Tu espacio de aprendizaje Wayuu está listo para comenzar.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8025),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  "Explorar cursos",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
