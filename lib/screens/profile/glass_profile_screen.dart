import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/common/glass_icon_badge.dart';
import '../../widgets/gamification/glass_hud_bar.dart';

class GlassProfileScreen extends StatelessWidget {
  const GlassProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Barra HUD Superior
              const GlassHudBar(),

              Expanded(
                child: Consumer2<AppProvider, ThemeProvider>(
                  builder: (context, provider, themeProvider, child) {
                    final user = provider.user;
                    final streak = provider.streak;

                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          provider.loadUserData(),
                          provider.loadStreak(),
                          provider.loadBadges(),
                        ]);
                      },
                      color: AppColors.primaryOrange,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        children: [
                          // 1. Tarjeta de Identidad del Usuario en Cristal
                          GlassCard(
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.primaryOrange.withOpacity(0.2),
                                  child: Text(
                                    user?.firstName.isNotEmpty == true
                                        ? user!.firstName[0].toUpperCase()
                                        : 'Y',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.fullName ?? 'Aprendiz Wayuu',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppColors.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user?.email ?? '',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: isDark ? Colors.white60 : AppColors.lightText,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'NIVEL ${user?.level ?? 1} • ${(user?.roleDisplayName ?? "Estudiante").toUpperCase()}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. Resumen de Estadísticas Gamificadas
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatMiniCard(
                                  icon: AppIcons.streak,
                                  iconColor: AppIcons.streakColor,
                                  value: '${streak?.currentStreak ?? 0} días',
                                  label: 'Racha Actual',
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatMiniCard(
                                  icon: AppIcons.xp,
                                  iconColor: AppIcons.xpColor,
                                  value: '${user?.xp ?? 0} XP',
                                  label: 'Experiencia',
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatMiniCard(
                                  icon: AppIcons.freezeToken,
                                  iconColor: AppIcons.freezeColor,
                                  value: '${streak?.freezeTokens ?? 0}',
                                  label: 'Tokens Racha',
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // 3. Selector de Tema Dual (Requisito Específico)
                          Text(
                            'APARIENCIA Y TEMA',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white54 : AppColors.lightText,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GlassCard(
                            borderRadius: BorderRadius.circular(20),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.palette_outlined,
                                      size: 22,
                                      color: isDark ? Colors.white : AppColors.darkText,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Tema de Cristal (Glassmorphism)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppColors.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _buildThemeOption(
                                      context: context,
                                      themeProvider: themeProvider,
                                      mode: ThemeMode.light,
                                      title: 'Claro',
                                      icon: Icons.light_mode_rounded,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildThemeOption(
                                      context: context,
                                      themeProvider: themeProvider,
                                      mode: ThemeMode.dark,
                                      title: 'Oscuro',
                                      icon: Icons.dark_mode_rounded,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildThemeOption(
                                      context: context,
                                      themeProvider: themeProvider,
                                      mode: ThemeMode.system,
                                      title: 'Sistema',
                                      icon: Icons.brightness_auto_rounded,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 4. Accesos a Acciones
                          Text(
                            'CUENTA Y AJUSTES',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white54 : AppColors.lightText,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _buildActionTile(
                            icon: Icons.edit_outlined,
                            title: 'Editar Perfil',
                            isDark: isDark,
                            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                          ),
                          const SizedBox(height: 8),

                          _buildActionTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notificaciones',
                            isDark: isDark,
                            badge: provider.unreadNotificationsCount > 0
                                ? '${provider.unreadNotificationsCount}'
                                : null,
                            onTap: () => Navigator.pushNamed(context, '/notifications'),
                          ),
                          const SizedBox(height: 8),

                          if (provider.canManage) ...[
                            _buildActionTile(
                              icon: Icons.admin_panel_settings_outlined,
                              title: 'Panel de Administración',
                              isDark: isDark,
                              onTap: () => Navigator.pushNamed(context, '/admin-stats'),
                            ),
                            const SizedBox(height: 8),
                          ],

                          _buildActionTile(
                            icon: Icons.logout_rounded,
                            title: 'Cerrar Sesión',
                            isDark: isDark,
                            textColor: AppColors.errorRed,
                            onTap: () async {
                              await provider.logout();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/welcome',
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatMiniCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          GlassIconBadge(
            icon: icon,
            color: iconColor,
            size: 38,
            iconSize: 20,
            borderRadius: 19,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? Colors.white54 : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required ThemeMode mode,
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = themeProvider.themeMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          themeProvider.setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(14),
        child: GlassContainer(
          height: 44,
          borderRadius: BorderRadius.circular(14),
          backgroundColor: isSelected
              ? AppColors.primaryOrange.withOpacity(isDark ? 0.35 : 0.22)
              : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
          borderGradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryOrange,
                    AppColors.primaryOrange.withOpacity(0.3),
                  ],
                )
              : null,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected
                    ? AppColors.primaryOrange
                    : (isDark ? Colors.white60 : AppColors.lightText),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryOrange
                      : (isDark ? Colors.white70 : AppColors.darkText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
    Color? textColor,
    String? badge,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: textColor ?? (isDark ? Colors.white70 : AppColors.darkText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textColor ?? (isDark ? Colors.white : AppColors.darkText),
              ),
            ),
          ),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
        ],
      ),
    );
  }
}
