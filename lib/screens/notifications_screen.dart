import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Notificaciones de ejemplo (en producción vendrían del backend)
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'type': 'level_up',
      'title': '¡Subiste de nivel!',
      'message': 'Has alcanzado el nivel 2. ¡Sigue así!',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': 2,
      'type': 'new_course',
      'title': 'Nuevo curso disponible',
      'message': 'El curso "Wayuunaiki Avanzado" ya está disponible',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': false,
    },
    {
      'id': 3,
      'type': 'quiz_passed',
      'title': 'Quiz aprobado',
      'message': 'Aprobaste el quiz "Saludos básicos" con 95%',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
    },
    {
      'id': 4,
      'type': 'achievement',
      'title': 'Nueva insignia',
      'message': 'Desbloqueaste la insignia "Estudiante dedicado"',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
    },
  ];

  void _markAsRead(int id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n['id'] == id);
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Notificaciones'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Marcar todas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.whiteText,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none,
              title: 'Sin notificaciones',
              message: 'No tienes notificaciones en este momento',
            )
          : Column(
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
                  child: ListView.separated(
                    padding: AppStyles.screenPadding,
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppStyles.spacingM),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;

    return InkWell(
      onTap: () => _markAsRead(notification['id']),
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
                color: _getNotificationColor(type).withOpacity(0.1),
                borderRadius: AppStyles.smallBorderRadius,
              ),
              child: Icon(
                _getNotificationIcon(type),
                color: _getNotificationColor(type),
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
                          notification['title'],
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
                    notification['message'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification['time']),
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'level_up':
        return Icons.trending_up;
      case 'new_course':
        return Icons.school_outlined;
      case 'quiz_passed':
        return Icons.check_circle_outline;
      case 'achievement':
        return Icons.emoji_events_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'level_up':
        return AppColors.primaryOrange;
      case 'new_course':
        return AppColors.primaryBlue;
      case 'quiz_passed':
        return AppColors.successGreen;
      case 'achievement':
        return AppColors.warningYellow;
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
