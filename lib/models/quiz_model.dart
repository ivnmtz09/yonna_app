import 'package:flutter/material.dart';

class QuizModel {
  final int id;
  final String title;
  final String description;
  final int course;
  final String courseTitle;
  final String difficulty;
  final double passingScore;
  final int xpReward;
  final int timeLimit; // en minutos
  final bool isActive;
  final int maxAttempts;
  final int createdBy;
  final DateTime createdAt;

  // Campos calculados desde el backend
  final int questionCount;
  final double averageScore;
  final double completionRate;
  final int userAttempts;
  final bool canAttempt;
  final double bestScore;

  // Preguntas (opcional, solo en detalle)
  final List<QuestionModel> questions;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.course,
    required this.courseTitle,
    required this.difficulty,
    required this.passingScore,
    required this.xpReward,
    required this.timeLimit,
    required this.isActive,
    required this.maxAttempts,
    required this.createdBy,
    required this.createdAt,
    this.questionCount = 0,
    this.averageScore = 0.0,
    this.completionRate = 0.0,
    this.userAttempts = 0,
    this.canAttempt = true,
    this.bestScore = 0.0,
    this.questions = const [],
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      course: json['course'] ?? 0,
      courseTitle: json['course_title'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      passingScore: (json['passing_score'] ?? 70.0).toDouble(),
      xpReward: json['xp_reward'] ?? 50,
      timeLimit: json['time_limit'] ?? 10,
      isActive: json['is_active'] ?? true,
      maxAttempts: json['max_attempts'] ?? 3,
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      questionCount: json['question_count'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      userAttempts: json['user_attempts'] ?? 0,
      canAttempt: json['can_attempt'] ?? true,
      bestScore: (json['best_score'] ?? 0.0).toDouble(),
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuestionModel.fromJson(q))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course': course,
      'course_title': courseTitle,
      'difficulty': difficulty,
      'passing_score': passingScore,
      'xp_reward': xpReward,
      'time_limit': timeLimit,
      'is_active': isActive,
      'max_attempts': maxAttempts,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'question_count': questionCount,
      'average_score': averageScore,
      'completion_rate': completionRate,
      'user_attempts': userAttempts,
      'can_attempt': canAttempt,
      'best_score': bestScore,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  // Getters útiles para la UI
  String get formattedTimeLimit => '$timeLimit min';
  bool get hasTimeLimit => timeLimit > 0;

  String get difficultyDisplayName {
    switch (difficulty) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Medio';
      case 'hard':
        return 'Difícil';
      default:
        return 'Medio';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  bool get isCompleted => userAttempts > 0;
  bool get isPassed => bestScore >= passingScore;
  bool get canRetake => !isPassed && userAttempts < maxAttempts;
  int get attemptsRemaining => maxAttempts - userAttempts;
}

class QuestionModel {
  final int id;
  final String text;
  final String questionType;
  final List<String> options;
  final int order;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.text,
    required this.questionType,
    required this.options,
    required this.order,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      questionType: json['question_type'] ?? 'multiple_choice',
      options:
          json['options'] != null ? List<String>.from(json['options']) : [],
      order: json['order'] ?? 0,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'question_type': questionType,
      'options': options,
      'order': order,
      'explanation': explanation,
    };
  }

  bool get isMultipleChoice => questionType == 'multiple_choice';
  bool get isTrueFalse => questionType == 'true_false';
  bool get isShortAnswer => questionType == 'short_answer';
}

class QuizAttemptModel {
  final int id;
  final int quiz;
  final String quizTitle;
  final String courseTitle;
  final double score;
  final bool passed;
  final int timeTaken; // en segundos
  final Map<String, dynamic> answers;
  final int attemptNumber;
  final bool canRetake;
  final DateTime completedAt;

  QuizAttemptModel({
    required this.id,
    required this.quiz,
    required this.quizTitle,
    required this.courseTitle,
    required this.score,
    required this.passed,
    required this.timeTaken,
    required this.answers,
    required this.attemptNumber,
    required this.canRetake,
    required this.completedAt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] ?? 0,
      quiz: json['quiz'] ?? 0,
      quizTitle: json['quiz_title'] ?? '',
      courseTitle: json['course_title'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      passed: json['passed'] ?? false,
      timeTaken: json['time_taken'] ?? 0,
      answers: json['answers'] ?? {},
      attemptNumber: json['attempt_number'] ?? 1,
      canRetake: json['can_retake'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz': quiz,
      'quiz_title': quizTitle,
      'course_title': courseTitle,
      'score': score,
      'passed': passed,
      'time_taken': timeTaken,
      'answers': answers,
      'attempt_number': attemptNumber,
      'can_retake': canRetake,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  String get formattedTime {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes}m ${seconds}s';
  }

  String get scorePercentage => '${score.toStringAsFixed(1)}%';
  String get statusText => passed ? 'Aprobado' : 'No aprobado';
  Color get statusColor => passed ? Colors.green : Colors.red;
}

// Modelo para enviar un quiz
class SubmitQuizRequest {
  final int quizId;
  final Map<String, String> answers; // question_id: answer
  final int timeTaken; // en segundos

  SubmitQuizRequest({
    required this.quizId,
    required this.answers,
    required this.timeTaken,
  });

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'answers': answers,
      'time_taken': timeTaken,
    };
  }
}

// Respuesta al enviar un quiz
class SubmitQuizResponse {
  final String message;
  final QuizAttemptModel attempt;
  final int xpGained;
  final int currentLevel;
  final int totalXp;

  SubmitQuizResponse({
    required this.message,
    required this.attempt,
    required this.xpGained,
    required this.currentLevel,
    required this.totalXp,
  });

  factory SubmitQuizResponse.fromJson(Map<String, dynamic> json) {
    return SubmitQuizResponse(
      message: json['message'] ?? '',
      attempt: QuizAttemptModel.fromJson(json['attempt']),
      xpGained: json['xp_gained'] ?? 0,
      currentLevel: json['current_level'] ?? 1,
      totalXp: json['total_xp'] ?? 0,
    );
  }
}

// Modelo para crear quiz (admin/moderator)
class CreateQuizRequest {
  final String title;
  final String description;
  final int course;
  final String difficulty;
  final double passingScore;
  final int xpReward;
  final int timeLimit;
  final int maxAttempts;
  final List<CreateQuestionRequest>? questions;

  CreateQuizRequest({
    required this.title,
    required this.description,
    required this.course,
    this.difficulty = 'medium',
    this.passingScore = 70.0,
    this.xpReward = 50,
    this.timeLimit = 10,
    this.maxAttempts = 3,
    this.questions,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'title': title,
      'description': description,
      'course': course,
      'difficulty': difficulty,
      'passing_score': passingScore,
      'xp_reward': xpReward,
      'time_limit': timeLimit,
      'max_attempts': maxAttempts,
    };

    if (questions != null && questions!.isNotEmpty) {
      json['questions'] = questions!.map((q) => q.toJson()).toList();
    }

    return json;
  }
}

class CreateQuestionRequest {
  final String text;
  final String questionType;
  final List<String> options;
  final int order;
  final String? explanation;

  CreateQuestionRequest({
    required this.text,
    this.questionType = 'multiple_choice',
    this.options = const [],
    this.order = 0,
    this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'question_type': questionType,
      'options': options,
      'order': order,
      'explanation': explanation,
    };
  }
}
