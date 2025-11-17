// Modelo para historial de XP
class XpHistoryModel {
  final int id;
  final int xpGained;
  final String source;
  final String sourceDisplay;
  final String? description;
  final int? relatedQuiz;
  final String? quizTitle;
  final int? relatedCourse;
  final String? courseTitle;
  final String formattedDate;
  final DateTime createdAt;

  XpHistoryModel({
    required this.id,
    required this.xpGained,
    required this.source,
    required this.sourceDisplay,
    this.description,
    this.relatedQuiz,
    this.quizTitle,
    this.relatedCourse,
    this.courseTitle,
    required this.formattedDate,
    required this.createdAt,
  });

  factory XpHistoryModel.fromJson(Map<String, dynamic> json) {
    return XpHistoryModel(
      id: json['id'] ?? 0,
      xpGained: json['xp_gained'] ?? 0,
      source: json['source'] ?? '',
      sourceDisplay: json['source_display'] ?? '',
      description: json['description'],
      relatedQuiz: json['related_quiz'],
      quizTitle: json['quiz_title'],
      relatedCourse: json['related_course'],
      courseTitle: json['course_title'],
      formattedDate: json['formatted_date'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'xp_gained': xpGained,
      'source': source,
      'source_display': sourceDisplay,
      'description': description,
      'related_quiz': relatedQuiz,
      'quiz_title': quizTitle,
      'related_course': relatedCourse,
      'course_title': courseTitle,
      'formatted_date': formattedDate,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Modelo para estadísticas del usuario
class UserStatisticsModel {
  final int id;
  final String userName;
  final String userEmail;
  final int userLevel;
  final int totalQuizzesAttempted;
  final int totalQuizzesPassed;
  final double quizSuccessRate;
  final double averageQuizScore;
  final int totalCoursesStarted;
  final int totalCoursesCompleted;
  final double courseCompletionRate;
  final int totalXpEarned;
  final int currentStreakDays;
  final int longestStreakDays;
  final int daysActive;
  final DateTime? lastActiveDate;
  final DateTime updatedAt;

  UserStatisticsModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userLevel,
    required this.totalQuizzesAttempted,
    required this.totalQuizzesPassed,
    required this.quizSuccessRate,
    required this.averageQuizScore,
    required this.totalCoursesStarted,
    required this.totalCoursesCompleted,
    required this.courseCompletionRate,
    required this.totalXpEarned,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.daysActive,
    this.lastActiveDate,
    required this.updatedAt,
  });

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) {
    return UserStatisticsModel(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userLevel: json['user_level'] ?? 1,
      totalQuizzesAttempted: json['total_quizzes_attempted'] ?? 0,
      totalQuizzesPassed: json['total_quizzes_passed'] ?? 0,
      quizSuccessRate: (json['quiz_success_rate'] ?? 0.0).toDouble(),
      averageQuizScore: (json['average_quiz_score'] ?? 0.0).toDouble(),
      totalCoursesStarted: json['total_courses_started'] ?? 0,
      totalCoursesCompleted: json['total_courses_completed'] ?? 0,
      courseCompletionRate: (json['course_completion_rate'] ?? 0.0).toDouble(),
      totalXpEarned: json['total_xp_earned'] ?? 0,
      currentStreakDays: json['current_streak_days'] ?? 0,
      longestStreakDays: json['longest_streak_days'] ?? 0,
      daysActive: json['days_active'] ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_email': userEmail,
      'user_level': userLevel,
      'total_quizzes_attempted': totalQuizzesAttempted,
      'total_quizzes_passed': totalQuizzesPassed,
      'quiz_success_rate': quizSuccessRate,
      'average_quiz_score': averageQuizScore,
      'total_courses_started': totalCoursesStarted,
      'total_courses_completed': totalCoursesCompleted,
      'course_completion_rate': courseCompletionRate,
      'total_xp_earned': totalXpEarned,
      'current_streak_days': currentStreakDays,
      'longest_streak_days': longestStreakDays,
      'days_active': daysActive,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Modelo para overview de estadísticas
class StatsOverviewModel {
  final int userLevel;
  final int userXp;
  final int nextLevelXp;
  final double progressToNextLevel;
  final int weeklyXpGain;
  final int monthlyXpGain;
  final int coursesCompleted;
  final int quizzesAttempted;
  final int quizzesPassed;
  final double successRate;
  final int currentStreak;
  final int rank;

  StatsOverviewModel({
    required this.userLevel,
    required this.userXp,
    required this.nextLevelXp,
    required this.progressToNextLevel,
    required this.weeklyXpGain,
    required this.monthlyXpGain,
    required this.coursesCompleted,
    required this.quizzesAttempted,
    required this.quizzesPassed,
    required this.successRate,
    required this.currentStreak,
    required this.rank,
  });

  factory StatsOverviewModel.fromJson(Map<String, dynamic> json) {
    return StatsOverviewModel(
      userLevel: json['user_level'] ?? 1,
      userXp: json['user_xp'] ?? 0,
      nextLevelXp: json['next_level_xp'] ?? 100,
      progressToNextLevel: (json['progress_to_next_level'] ?? 0.0).toDouble(),
      weeklyXpGain: json['weekly_xp_gain'] ?? 0,
      monthlyXpGain: json['monthly_xp_gain'] ?? 0,
      coursesCompleted: json['courses_completed'] ?? 0,
      quizzesAttempted: json['quizzes_attempted'] ?? 0,
      quizzesPassed: json['quizzes_passed'] ?? 0,
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_level': userLevel,
      'user_xp': userXp,
      'next_level_xp': nextLevelXp,
      'progress_to_next_level': progressToNextLevel,
      'weekly_xp_gain': weeklyXpGain,
      'monthly_xp_gain': monthlyXpGain,
      'courses_completed': coursesCompleted,
      'quizzes_attempted': quizzesAttempted,
      'quizzes_passed': quizzesPassed,
      'success_rate': successRate,
      'current_streak': currentStreak,
      'rank': rank,
    };
  }
}

// Modelo para series de tiempo
class TimeSeriesData {
  final DateTime date;
  final int value;
  final String? label;

  TimeSeriesData({
    required this.date,
    required this.value,
    this.label,
  });

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) {
    return TimeSeriesData(
      date: DateTime.parse(json['date']),
      value: json['value'] ?? 0,
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'value': value,
      'label': label,
    };
  }
}
