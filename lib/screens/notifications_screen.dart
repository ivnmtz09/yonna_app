import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/notification_model.dart';
import '../widgets/app_styles.dart';
import '../widgets/empty_state.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Notificaciones'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.unreadNotificationsCount > 0) {
                return TextButton(
                  onPressed: () => provider.markAllNotificationsAsRead(),
                  child: Text(
                    'Marcar todas',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.whiteText,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'Sin notificaciones',
              message: 'No tienes notificaciones en este momento',
            );
          }

          final notifications = provider.notifications;
          final unreadCount = provider.unreadNotificationsCount;

          return Column(
            children: [
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                      const SizedBox(width: AppStyles.spacingS),
                      Text(
                        '$unreadCount ${unreadCount == 1 ? 'notificación nueva' : 'notificaciones nuevas'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadNotifications(),
                  color: AppColors.primaryOrange,
                  child: ListView.separated(
                    padding: AppStyles.screenPadding,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppStyles.spacingM),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(notification, provider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    AppProvider provider,
  ) {
    final isRead = notification.isRead;

    return InkWell(
      onTap: () {
        if (!isRead) {
          provider.markNotificationAsRead(notification.id);
        }
        // Navegar a contenido relacionado si existe
        _handleNotificationTap(notification, context);
      },
      borderRadius: AppStyles.standardBorderRadius,
      child: Container(
        padding: AppStyles.cardPadding,
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.backgroundWhite
              : AppColors.primaryOrange.withOpacity(0.05),
          borderRadius: AppStyles.standardBorderRadius,
          border: Border.all(
            color: isRead
                ? AppColors.lightText.withOpacity(0.1)
                : AppColors.primaryOrange.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _getNotificationColor(notification.type).withOpacity(0.1),
                borderRadius: AppStyles.smallBorderRadius,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 24,
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isRead
                                ? AppColors.darkText
                                : AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      if (!isRead)
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
                    notification.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.lightText.withOpacity(0.7),
                      fontSize: 11,
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

  void _handleNotificationTap(
      NotificationModel notification, BuildContext context) {
    // Navegar a contenido relacionado según el tipo de notificación
    if (notification.relatedCourseId != null) {
      // Navegar al curso
      // Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailScreen(courseId: notification.relatedCourseId!)));
    } else if (notification.relatedQuizId != null) {
      // Navegar al quiz
      // Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(quizId: notification.relatedQuizId!)));
    }
    // Para notificaciones de nivel up, quiz_passed, etc., no hacer nada o mostrar detalles
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'level_up':
        return Icons.trending_up;
      case 'new_course':
        return Icons.school_outlined;
      case 'quiz_result':
      case 'progress_update':
        return Icons.assignment_turned_in_outlined;
      case 'achievement':
      case 'reward_unlocked':
        return Icons.emoji_events_outlined;
      case 'study_streak':
        return Icons.local_fire_department_outlined;
      case 'new_quiz':
        return Icons.quiz_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'level_up':
        return AppColors.primaryOrange;
      case 'new_course':
      case 'new_quiz':
        return AppColors.primaryBlue;
      case 'quiz_result':
      case 'progress_update':
        return AppColors.successGreen;
      case 'achievement':
      case 'reward_unlocked':
        return AppColors.warningYellow;
      case 'study_streak':
        return AppColors.errorRed;
      default:
        return AppColors.primaryOrange;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

