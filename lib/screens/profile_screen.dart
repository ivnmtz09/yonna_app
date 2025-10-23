import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Obtenemos la instancia Singleton del servicio
  final ApiService _apiService = ApiService();

  // Leemos los datos directamente de la caché en memoria del servicio
  late final Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    // No hay llamada asíncrona. Los datos ya están cargados.
    _userData = _apiService.userData;
  }

  Future<void> _handleLogout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Construimos el nombre completo a partir de los datos
    final String fullName =
        '${_userData['first_name'] ?? ''} ${_userData['last_name'] ?? ''}'
            .trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shadowColor: AppColors.primaryGreen.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: AppStyles.standardBorderRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/saludo.png', height: 120),
                    const SizedBox(height: 20),
                    Text(
                      fullName.isEmpty ? 'Usuario Yonna' : fullName,
                      textAlign: TextAlign.center,
                      style: AppStyles.mainTitleStyle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 24),
                    _buildProfileInfoRow(
                      icon: Icons.email_outlined,
                      text: _userData['email'] ?? 'Sin email',
                    ),
                    const SizedBox(height: 12),
                    _buildProfileInfoRow(
                      icon: Icons.star_border_outlined,
                      text: "Nivel: ${_userData['level'] ?? 'Principiante'}",
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(), // Empuja el botón hacia abajo
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.standardBorderRadius),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: AppColors.darkText),
          ),
        ),
      ],
    );
  }
}
