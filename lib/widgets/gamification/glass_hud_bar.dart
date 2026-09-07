import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_styles.dart';
import '../glass/glass_container.dart';

class GlassHudBar extends StatelessWidget {
  final VoidCallback? onNotificationsTap;

  const GlassHudBar({
    super.key,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<AppProvider, ThemeProvider>(
      builder: (context, appProvider, themeProvider, child) {
        final user = appProvider.user;
        final streak = appProvider.currentStreak;
        final freezeTokens = appProvider.freezeTokens;
        final level = user?.level ?? 1;
        final xp = user?.xp ?? 0;
        final unread = appProvider.unreadNotificationsCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 1. Racha Diaria (Fuego vectorial) con tokens de congelamiento
              GlassContainer(
                height: 42,
                borderRadius: BorderRadius.circular(21),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.85),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      AppIcons.streak,
                      color: AppIcons.streakColor,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$streak',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    if (freezeTokens > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              AppIcons.freezeToken,
                              color: AppIcons.freezeColor,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$freezeTokens',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 2. Nivel & XP (Duolingo XP Bar Minimalista)
              Expanded(
                child: GlassContainer(
                  height: 42,
                  borderRadius: BorderRadius.circular(21),
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'LVL $level',
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$xp XP',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFF1F5F9)
                                        : AppColors.darkText,
                                  ),
                                ),
                                Text(
                                  '${user?.xpForNextLevel ?? 100} XP',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: user?.levelProgress ?? 0.2,
                                backgroundColor: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.06),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryOrange,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 3. Toggle Rápido de Tema (Claro/Oscuro/Sistema)
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  themeProvider.cycleThemeMode();
                },
                borderRadius: BorderRadius.circular(21),
                child: GlassContainer(
                  width: 42,
                  height: 42,
                  borderRadius: BorderRadius.circular(21),
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.85),
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Icon(
                      themeProvider.themeIcon,
                      size: 19,
                      color: isDark ? const Color(0xFFF1F5F9) : AppColors.darkText,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // 4. Notificaciones
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onNotificationsTap != null) {
                    onNotificationsTap!();
                  } else {
                    Navigator.pushNamed(context, '/notifications');
                  }
                },
                borderRadius: BorderRadius.circular(21),
                child: GlassContainer(
                  width: 42,
                  height: 42,
                  borderRadius: BorderRadius.circular(21),
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.85),
                  padding: EdgeInsets.zero,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 21,
                        color: isDark ? const Color(0xFFF1F5F9) : AppColors.darkText,
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
