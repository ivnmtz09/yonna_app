import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final int? relatedCourseId;
  final int? relatedQuizId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedCourseId,
    this.relatedQuizId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      relatedCourseId: json['related_course_id'],
      relatedQuizId: json['related_quiz_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'related_course_id': relatedCourseId,
      'related_quiz_id': relatedQuizId,
    };
  }

  // Getters para tipos de notificación según el backend
  bool get isNewCourse => type == 'new_course';
  bool get isNewQuiz => type == 'new_quiz';
  bool get isProgressUpdate => type == 'progress_update';
  bool get isLevelUp => type == 'level_up';
  bool get isUserReport => type == 'user_report';
  bool get isCourseCompleted => type == 'course_completed';
  bool get isNewModerator => type == 'new_moderator';
  bool get isSystemError => type == 'system_error';
  bool get isStudyStreak => type == 'study_streak';
  bool get isRewardUnlocked => type == 'reward_unlocked';
  bool get isSystem => type == 'system';

  IconData get icon {
    switch (type) {
      case 'new_course':
        return Icons.school;
      case 'new_quiz':
        return Icons.assignment;
      case 'progress_update':
        return Icons.trending_up;
      case 'level_up':
        return Icons.emoji_events;
      case 'user_report':
        return Icons.report_problem;
      case 'course_completed':
        return Icons.celebration;
      case 'new_moderator':
        return Icons.admin_panel_settings;
      case 'system_error':
        return Icons.error;
      case 'study_streak':
        return Icons.local_fire_department;
      case 'reward_unlocked':
        return Icons.workspace_premium;
      default:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case 'new_course':
        return Colors.blue;
      case 'new_quiz':
        return Colors.blue;
      case 'progress_update':
        return Colors.green;
      case 'level_up':
        return Colors.orange;
      case 'user_report':
        return Colors.orange;
      case 'course_completed':
        return Colors.green;
      case 'new_moderator':
        return Colors.purple;
      case 'system_error':
        return Colors.red;
      case 'study_streak':
        return Colors.red;
      case 'reward_unlocked':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Ahora mismo';
    }
  }
}

// Modelo para marcar notificaciones como leídas
class MarkNotificationsReadRequest {
  final List<int> notificationIds;

  MarkNotificationsReadRequest({required this.notificationIds});

  Map<String, dynamic> toJson() {
    return {
      'notification_ids': notificationIds,
    };
  }
}

// Respuesta al marcar notificaciones
class MarkNotificationsReadResponse {
  final String message;
  final int updatedCount;

  MarkNotificationsReadResponse({
    required this.message,
    required this.updatedCount,
  });

  factory MarkNotificationsReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkNotificationsReadResponse(
      message: json['message'] ?? '',
      updatedCount: json['updated_count'] ?? 0,
    );
  }
}
