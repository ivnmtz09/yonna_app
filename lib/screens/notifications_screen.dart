import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_icons.dart';
import '../models/notification_model.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/common/glass_icon_badge.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior de cristal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(21),
                      child: GlassContainer(
                        width: 42,
                        height: 42,
                        borderRadius: BorderRadius.circular(21),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    Consumer<AppProvider>(
                      builder: (context, provider, child) {
                        if (provider.unreadNotificationsCount > 0) {
                          return TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              provider.markAllNotificationsAsRead();
                            },
                            child: const Text(
                              'Marcar leídas',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              // Lista de notificaciones
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.notifications.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOrange,
                        ),
                      );
                    }

                    if (provider.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GlassIconBadge(
                              icon: Icons.notifications_off_outlined,
                              color: isDark ? Colors.white38 : AppColors.lightText,
                              size: 72,
                              iconSize: 34,
                              borderRadius: 36,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tienes notificaciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Te avisaremos sobre tus rachas, nuevos quizzes y logros',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark ? Colors.white60 : AppColors.lightText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.loadNotifications(),
                      color: AppColors.primaryOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: provider.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = provider.notifications[index];
                          return _buildNotificationCard(notif, provider, isDark);
                        },
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

  Widget _buildNotificationCard(
    NotificationModel notif,
    AppProvider provider,
    bool isDark,
  ) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case 'streak_reminder':
        icon = AppIcons.streak;
        iconColor = AppIcons.streakColor;
        break;
      case 'level_up':
        icon = AppIcons.level;
        iconColor = AppColors.primaryOrange;
        break;
      case 'new_badge':
        icon = AppIcons.badge;
        iconColor = AppIcons.goldColor;
        break;
      case 'quiz_result':
        icon = AppIcons.quiz;
        iconColor = AppIcons.successColor;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.primaryBlue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: BorderRadius.circular(18),
        backgroundColor: notif.isRead
            ? (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.70))
            : AppColors.primaryOrange.withValues(alpha: isDark ? 0.16 : 0.10),
        onTap: () {
          if (!notif.isRead) {
            provider.markNotificationAsRead(notif.id);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassIconBadge(
              icon: icon,
              color: iconColor,
              size: 42,
              iconSize: 20,
              borderRadius: 21,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.darkText,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.white70 : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notif.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }
}
