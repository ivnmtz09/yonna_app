import 'package:flutter/material.dart';

class CourseModel {
  final int id;
  final String title;
  final String description;
  final int levelRequired;
  final bool isActive;
  final String? thumbnail;
  final int estimatedDuration; // en horas
  final String difficulty;
  final int createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos calculados desde el backend
  final int enrolledStudentsCount;
  final int completedStudentsCount;
  final int quizCount;
  final bool isEnrolled;
  final double userProgress;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.levelRequired,
    required this.isActive,
    this.thumbnail,
    required this.estimatedDuration,
    required this.difficulty,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.enrolledStudentsCount = 0,
    this.completedStudentsCount = 0,
    this.quizCount = 0,
    this.isEnrolled = false,
    this.userProgress = 0.0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      levelRequired: json['level_required'] ?? 1,
      isActive: json['is_active'] ?? true,
      thumbnail: json['thumbnail'],
      estimatedDuration: json['estimated_duration'] ?? 4,
      difficulty: json['difficulty'] ?? 'beginner',
      createdBy: json['created_by'] ?? 0,
      createdByName: json['created_by_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      enrolledStudentsCount: json['enrolled_students_count'] ?? 0,
      completedStudentsCount: json['completed_students_count'] ?? 0,
      quizCount: json['quiz_count'] ?? 0,
      isEnrolled: json['is_enrolled'] ?? false,
      userProgress: (json['user_progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level_required': levelRequired,
      'is_active': isActive,
      'thumbnail': thumbnail,
      'estimated_duration': estimatedDuration,
      'difficulty': difficulty,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'enrolled_students_count': enrolledStudentsCount,
      'completed_students_count': completedStudentsCount,
      'quiz_count': quizCount,
      'is_enrolled': isEnrolled,
      'user_progress': userProgress,
    };
  }

  // Getters útiles para la UI
  String get formattedDuration => '${estimatedDuration}h';

  String get difficultyDisplayName {
    switch (difficulty) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return 'Principiante';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  double get completionRate {
    if (enrolledStudentsCount == 0) return 0.0;
    return completedStudentsCount / enrolledStudentsCount;
  }

  bool get isCompleted => userProgress >= 100.0;

  // Alias para compatibilidad
  int get level => levelRequired;
  int get enrolledCount => enrolledStudentsCount;
}

// Modelo para crear/actualizar curso (admin/moderator)
class CreateCourseRequest {
  final String title;
  final String description;
  final int levelRequired;
  final String? thumbnail;
  final int estimatedDuration;
  final String difficulty;

  CreateCourseRequest({
    required this.title,
    required this.description,
    this.levelRequired = 1,
    this.thumbnail,
    this.estimatedDuration = 4,
    this.difficulty = 'beginner',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'level_required': levelRequired,
      'thumbnail': thumbnail,
      'estimated_duration': estimatedDuration,
      'difficulty': difficulty,
    };
  }
}

// Modelo para inscripción en curso
class EnrollmentModel {
  final int id;
  final int course;
  final String courseTitle;
  final int courseLevel;
  final double progress;
  final bool courseCompleted;
  final DateTime? completedAt;
  final DateTime enrolledAt;
  final DateTime lastAccessed;

  EnrollmentModel({
    required this.id,
    required this.course,
    required this.courseTitle,
    required this.courseLevel,
    required this.progress,
    required this.courseCompleted,
    this.completedAt,
    required this.enrolledAt,
    required this.lastAccessed,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? 0,
      course: json['course'] ?? 0,
      courseTitle: json['course_title'] ?? '',
      courseLevel: json['course_level'] ?? 1,
      progress: (json['progress'] ?? 0.0).toDouble(),
      courseCompleted: json['course_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'])
          : DateTime.now(),
      lastAccessed: json['last_accessed'] != null
          ? DateTime.parse(json['last_accessed'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'course_title': courseTitle,
      'course_level': courseLevel,
      'progress': progress,
      'course_completed': courseCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'enrolled_at': enrolledAt.toIso8601String(),
      'last_accessed': lastAccessed.toIso8601String(),
    };
  }
}
