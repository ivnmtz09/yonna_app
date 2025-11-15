import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';
import '../widgets/yonna_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yonna App"),
      ),
      drawer: YonnaDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/mascota.png', height: 160),
              const SizedBox(height: 32),
              const Text(
                "Próximamente",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Nuevos juegos y actividades se habilitarán muy pronto.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.darkText.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
