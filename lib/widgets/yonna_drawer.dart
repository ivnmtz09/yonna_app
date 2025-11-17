import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yonna_app/providers/app_provider.dart';
import 'app_styles.dart';

class YonnaDrawer extends StatelessWidget {
  const YonnaDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final provider = context.read<AppProvider>();
    Navigator.pop(context); // Cerrar drawer
    await provider.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundWhite,
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final user = provider.user;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.whiteText,
                      child: Text(
                        user?.firstName.substring(0, 1).toUpperCase() ?? 'Y',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Usuario',
                      style: const TextStyle(
                        color: AppColors.whiteText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Nivel ${user?.level ?? 1} • ${user?.xp ?? 0} XP',
                      style: TextStyle(
                        color: AppColors.whiteText.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined,
                    color: AppColors.primaryOrange),
                title: Text('Inicio', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline,
                    color: AppColors.primaryOrange),
                title: Text('Mi Perfil', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined,
                    color: AppColors.primaryOrange),
                title: Text('Mis Cursos', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/courses');
                },
              ),
              ListTile(
                leading: const Icon(Icons.quiz_outlined,
                    color: AppColors.primaryOrange),
                title: Text('Quizzes', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/quizzes');
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up,
                    color: AppColors.primaryOrange),
                title: Text('Mi Progreso', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/progress');
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events_outlined,
                    color: AppColors.primaryOrange),
                title: Text('Clasificación', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/leaderboard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined,
                    color: AppColors.primaryOrange),
                title: Text('Notificaciones', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              if (provider.canManage) ...[
                const Divider(
                    color: AppColors.primaryOrange, indent: 16, endIndent: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    provider.isAdmin ? 'ADMINISTRADOR' : 'MODERADOR',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline,
                      color: AppColors.accentGreen),
                  title: Text('Crear Curso', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create-course');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined,
                      color: AppColors.accentGreen),
                  title: Text('Crear Quiz', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create-quiz');
                  },
                ),
                if (provider.isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.people_outline,
                        color: AppColors.primaryOrange),
                    title: Text('Gestionar Usuarios',
                        style: AppTextStyles.bodyMedium),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/manage-users');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart,
                        color: AppColors.primaryOrange),
                    title:
                        Text('Estadísticas', style: AppTextStyles.bodyMedium),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin-stats');
                    },
                  ),
                ],
              ],
              const Divider(
                  color: AppColors.primaryOrange, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.settings_outlined,
                    color: AppColors.primaryBlue),
                title: Text('Ajustes', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar pantalla de ajustes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pantalla de ajustes próximamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline,
                    color: AppColors.primaryBlue),
                title: Text('Ayuda', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar pantalla de ayuda
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Centro de ayuda próximamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(
                  color: AppColors.errorRed, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.errorRed),
                title: Text(
                  'Cerrar Sesión',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _handleLogout(context),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
