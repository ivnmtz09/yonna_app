class ProgressModel {
  final int id;
  final int course;
  final String courseTitle;
  final String courseDifficulty;
  final int completedQuizzes;
  final int totalQuizzes;
  final int remainingQuizzes;
  final double percentage;
  final int xpEarned;
  final bool courseCompleted;
  final DateTime? completedAt;
  final int streakDays;
  final double? estimatedCompletionTime; // en días
  final DateTime updatedAt;

  ProgressModel({
    required this.id,
    required this.course,
    required this.courseTitle,
    required this.courseDifficulty,
    required this.completedQuizzes,
    required this.totalQuizzes,
    required this.remainingQuizzes,
    required this.percentage,
    required this.xpEarned,
    required this.courseCompleted,
    this.completedAt,
    required this.streakDays,
    this.estimatedCompletionTime,
    required this.updatedAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] ?? 0,
      course: json['course']?['id'] ?? json['course'] ?? 0,
      courseTitle: json['course_title'] ?? json['course']?['title'] ?? '',
      courseDifficulty: json['course_difficulty'] ??
          json['course']?['difficulty'] ??
          'beginner',
      completedQuizzes: json['completed_quizzes'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
      remainingQuizzes: json['remaining_quizzes'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      xpEarned: json['xp_earned'] ?? 0,
      courseCompleted: json['course_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      streakDays: json['streak_days'] ?? 0,
      estimatedCompletionTime: json['estimated_completion_time'] != null
          ? (json['estimated_completion_time']).toDouble()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'course_title': courseTitle,
      'course_difficulty': courseDifficulty,
      'completed_quizzes': completedQuizzes,
      'total_quizzes': totalQuizzes,
      'remaining_quizzes': remainingQuizzes,
      'percentage': percentage,
      'xp_earned': xpEarned,
      'course_completed': courseCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'streak_days': streakDays,
      'estimated_completion_time': estimatedCompletionTime,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get progressText {
    if (courseCompleted) {
      return 'Completado';
    }
    return '$completedQuizzes/$totalQuizzes quizzes';
  }

  String get estimatedTimeText {
    if (estimatedCompletionTime == null) return 'N/A';

    if (estimatedCompletionTime! < 1) {
      final hours = (estimatedCompletionTime! * 24).round();
      return '$hours horas';
    } else if (estimatedCompletionTime! < 7) {
      return '${estimatedCompletionTime!.round()} días';
    } else {
      final weeks = (estimatedCompletionTime! / 7).round();
      return '$weeks semanas';
    }
  }
}

class GlobalProgressModel {
  final int id;
  final String userName;
  final int userLevel;
  final int userXp;
  final int totalCoursesEnrolled;
  final int totalCoursesCompleted;
  final int totalQuizzesCompleted;
  final int totalXpEarned;
  final double averageProgress;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;
  final DateTime updatedAt;

  GlobalProgressModel({
    required this.id,
    required this.userName,
    required this.userLevel,
    required this.userXp,
    required this.totalCoursesEnrolled,
    required this.totalCoursesCompleted,
    required this.totalQuizzesCompleted,
    required this.totalXpEarned,
    required this.averageProgress,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.updatedAt,
  });

  factory GlobalProgressModel.fromJson(Map<String, dynamic> json) {
    return GlobalProgressModel(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      userLevel: json['user_level'] ?? 1,
      userXp: json['user_xp'] ?? 0,
      totalCoursesEnrolled: json['total_courses_enrolled'] ?? 0,
      totalCoursesCompleted: json['total_courses_completed'] ?? 0,
      totalQuizzesCompleted: json['total_quizzes_completed'] ?? 0,
      totalXpEarned: json['total_xp_earned'] ?? 0,
      averageProgress: (json['average_progress'] ?? 0.0).toDouble(),
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_level': userLevel,
      'user_xp': userXp,
      'total_courses_enrolled': totalCoursesEnrolled,
      'total_courses_completed': totalCoursesCompleted,
      'total_quizzes_completed': totalQuizzesCompleted,
      'total_xp_earned': totalXpEarned,
      'average_progress': averageProgress,
      'completion_rate': completionRate,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Modelo para actualizar progreso
class UpdateProgressRequest {
  final int? courseId;

  UpdateProgressRequest({this.courseId});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (courseId != null) {
      json['course_id'] = courseId;
    }
    return json;
  }
}

// Respuesta de actualización de progreso
class UpdateProgressResponse {
  final String message;
  final ProgressModel? progress;
  final double? progressPercentage;
  final bool? courseCompleted;

  UpdateProgressResponse({
    required this.message,
    this.progress,
    this.progressPercentage,
    this.courseCompleted,
  });

  factory UpdateProgressResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProgressResponse(
      message: json['message'] ?? '',
      progress: json['progress'] != null
          ? ProgressModel.fromJson(json['progress'])
          : null,
      progressPercentage:
          json['progress'] != null ? (json['progress']).toDouble() : null,
      courseCompleted: json['course_completed'],
    );
  }
}

// Modelo para leaderboard
class LeaderboardEntry {
  final int rank;
  final int userId;
  final String userName;
  final int userLevel;
  final int userXp;
  final int totalCoursesCompleted;
  final int totalQuizzesCompleted;
  final int currentStreak;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.userLevel,
    required this.userXp,
    required this.totalCoursesCompleted,
    required this.totalQuizzesCompleted,
    required this.currentStreak,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      userLevel: json['user_level'] ?? 1,
      userXp: json['user_xp'] ?? 0,
      totalCoursesCompleted:
          json['courses_completed'] ?? json['total_courses_completed'] ?? 0,
      totalQuizzesCompleted: json['total_quizzes_completed'] ?? 0,
      currentStreak: json['streak_days'] ?? json['current_streak'] ?? 0,
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'user_name': userName,
      'user_level': userLevel,
      'user_xp': userXp,
      'courses_completed': totalCoursesCompleted,
      'total_quizzes_completed': totalQuizzesCompleted,
      'current_streak': currentStreak,
      'is_current_user': isCurrentUser,
    };
  }
}
