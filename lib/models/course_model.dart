class CourseModel {
  final int id;
  final String title;
  final String description;
  final int level;
  final String? imageUrl;
  final int enrolledCount;
  final bool isEnrolled;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    this.imageUrl,
    required this.enrolledCount,
    required this.isEnrolled,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      level: json['level'] ?? 1,
      imageUrl: json['image_url'],
      enrolledCount: json['enrolled_count'] ?? 0,
      isEnrolled: json['is_enrolled'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
