import 'package:flutter/material.dart';
import 'package:yonna_app/services/api_service.dart';
import 'app_styles.dart';

class YonnaDrawer extends StatelessWidget {
  // El constructor ya no es 'const'
  YonnaDrawer({super.key});

  // Obtenemos la instancia Singleton del servicio
  final ApiService _apiService = ApiService();

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Cierra el drawer
    await _apiService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext csontext) {
    return Drawer(
      backgroundColor: AppColors.backgroundWhite,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icon.png', height: 70),
                const SizedBox(height: 12),
                const Text(
                  'Yonna App',
                  style: TextStyle(
                    color: AppColors.backgroundWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.person_outline, color: AppColors.primaryGreen),
            title: const Text('Mi Perfil', style: AppStyles.drawerItemStyle),
            onTap: () {
              Navigator.pop(csontext);
              Navigator.pushNamed(csontext, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined,
                color: AppColors.primaryGreen),
            title: const Text('Ajustes', style: AppStyles.drawerItemStyle),
            onTap: () {
              Navigator.pop(csontext);
            },
          ),
          const Divider(
              color: AppColors.primaryGreen, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.accentOrange),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: AppColors.accentOrange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _handleLogout(csontext),
          ),
        ],
      ),
    );
  }
}
