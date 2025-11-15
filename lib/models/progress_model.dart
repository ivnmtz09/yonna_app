class ProgressModel {
  final int courseId;
  final String courseName;
  final double completionPercentage;
  final int xpEarned;
  final int quizzesCompleted;
  final int totalQuizzes;
  final DateTime enrolledAt;
  final DateTime? lastActivity;

  ProgressModel({
    required this.courseId,
    required this.courseName,
    required this.completionPercentage,
    required this.xpEarned,
    required this.quizzesCompleted,
    required this.totalQuizzes,
    required this.enrolledAt,
    this.lastActivity,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      courseId: json['course_id'],
      courseName: json['course_name'] ?? '',
      completionPercentage: (json['completion_percentage'] ?? 0).toDouble(),
      xpEarned: json['xp_earned'] ?? 0,
      quizzesCompleted: json['quizzes_completed'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
      enrolledAt: DateTime.parse(json['enrolled_at']),
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
    );
  }

  bool get isCompleted => completionPercentage >= 100;
}
