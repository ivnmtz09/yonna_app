import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/xp_progress_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final provider = context.read<AppProvider>();
    await provider.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final user = provider.user;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppStyles.screenPadding,
            child: Column(
              children: [
                // Tarjeta de información principal
                Container(
                  padding: AppStyles.cardPadding,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: AppStyles.standardBorderRadius,
                    boxShadow: AppStyles.largeShadow,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.whiteText,
                        child: Text(
                          user.firstName.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppStyles.spacingM),
                      Text(
                        user.fullName,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.whiteText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: AppStyles.smallBorderRadius,
                        ),
                        child: Text(
                          user.isTeacher ? 'Sabedor' : 'Estudiante',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.spacingL),

                // Barra de progreso XP
                XpProgressBar(
                  currentXp: user.xp,
                  xpForNextLevel: user.xpForNextLevel,
                  currentLevel: user.level,
                ),
                const SizedBox(height: AppStyles.spacingL),

                // Información de contacto
                _buildSectionCard(
                  title: 'Información de contacto',
                  children: [
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Correo',
                      value: user.email,
                    ),
                    if (user.telefono != null && user.telefono!.isNotEmpty) ...[
                      const Divider(height: AppStyles.spacingL),
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Teléfono',
                        value: user.telefono!,
                      ),
                    ],
                    if (user.localidad != null &&
                        user.localidad!.isNotEmpty) ...[
                      const Divider(height: AppStyles.spacingL),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Localidad',
                        value: user.localidad!,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppStyles.spacingL),

                // Intereses
                if (user.gustos != null && user.gustos!.isNotEmpty)
                  _buildSectionCard(
                    title: 'Intereses',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.gustos!.map((gusto) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withOpacity(0.1),
                              borderRadius: AppStyles.smallBorderRadius,
                              border: Border.all(
                                color: AppColors.primaryOrange.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              gusto,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: AppStyles.spacingL),

                // Estadísticas
                _buildSectionCard(
                  title: 'Estadísticas',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.school_outlined,
                            value: provider.courses
                                .where((c) => c.isEnrolled)
                                .length
                                .toString(),
                            label: 'Cursos',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: AppColors.lightText.withOpacity(0.2),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.quiz_outlined,
                            value: provider.quizzes
                                .where((q) => q.isCompleted)
                                .length
                                .toString(),
                            label: 'Quizzes',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: AppColors.lightText.withOpacity(0.2),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.emoji_events_outlined,
                            value: user.level.toString(),
                            label: 'Nivel',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.spacingXL),

                // Botón de cerrar sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    onPressed: () => _handleLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed.withOpacity(0.1),
                      foregroundColor: AppColors.errorRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppStyles.standardBorderRadius,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: AppStyles.spacingL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: AppStyles.spacingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryOrange, size: 20),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.lightText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryOrange, size: 28),
        const SizedBox(height: AppStyles.spacingS),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
