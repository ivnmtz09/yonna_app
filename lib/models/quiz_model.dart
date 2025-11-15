class QuizModel {
  final int id;
  final String title;
  final String description;
  final int courseId;
  final String courseName;
  final int totalQuestions;
  final int passingScore;
  final bool isCompleted;
  final int? lastScore;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.totalQuestions,
    required this.passingScore,
    required this.isCompleted,
    this.lastScore,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      courseId: json['course'],
      courseName: json['course_name'] ?? '',
      totalQuestions: json['total_questions'] ?? 10,
      passingScore: json['passing_score'] ?? 70,
      isCompleted: json['is_completed'] ?? false,
      lastScore: json['last_score'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isPassed => lastScore != null && lastScore! >= passingScore;
}
