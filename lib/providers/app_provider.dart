import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/quiz_model.dart';
import '../models/progress_model.dart';
import '../models/notification_model.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Exponer apiService para acceso directo
  ApiService get apiService => _apiService;

  // ========== ESTADO ==========
  
  // Usuario
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Datos
  List<CourseModel> _courses = [];
  List<QuizModel> _quizzes = [];
  List<ProgressModel> _progress = [];
  List<NotificationModel> _notifications = [];
  List<QuizAttemptModel> _quizAttempts = [];
  int _unreadNotificationsCount = 0;

  // ========== GETTERS ==========
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<CourseModel> get courses => _courses;
  List<QuizModel> get quizzes => _quizzes;
  List<ProgressModel> get progress => _progress;
  List<NotificationModel> get notifications => _notifications;
  List<QuizAttemptModel> get quizAttempts => _quizAttempts;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isModerator => _user?.isModerator ?? false;
  bool get isUser => _user?.isUser ?? false;
  bool get canManage => _user?.canManage ?? false;

  // ========== INICIALIZACIÓN ==========
  
  Future<void> initializeApp() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (await _apiService.isLoggedIn()) {
        await loadUserData();
        await _loadInitialData();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al inicializar la aplicación';
      _isLoading = false;
      notifyListeners();
      print('❌ Error en initializeApp: $e');
    }
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        loadCourses(),
        loadQuizzes(),
        loadProgress(),
        loadNotifications(),
      ]);
    } catch (e) {
      print('❌ Error cargando datos iniciales: $e');
    }
  }

  // ========== AUTENTICACIÓN ==========
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.login(email: email, password: password);

      if (data.containsKey('access')) {
        _user = UserModel.fromJson(data);
        await _loadInitialData();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = data['detail'] ?? 'Error al iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ')[1]
          : 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password1,
    required String password2,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password1: password1,
        password2: password2,
      );

      if (data.containsKey('email')) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      if (data.values.isNotEmpty && data.values.first is List) {
        _error = data.values.first[0];
      } else {
        _error = data.toString();
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _courses = [];
    _quizzes = [];
    _progress = [];
    _notifications = [];
    _quizAttempts = [];
    _unreadNotificationsCount = 0;
    notifyListeners();
  }

  // ========== USER ==========
  
  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.getProfile();
      _user = UserModel.fromJson(data);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar datos del usuario';
      _isLoading = false;
      notifyListeners();
      print('❌ Error en loadUserData: $e');
    }
  }

  Future<bool> updateProfile({
    String? telefono,
    String? localidad,
    List<String>? gustos,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _apiService.updateProfile(
        telefono: telefono,
        localidad: localidad,
        gustos: gustos,
      );

      _user = UserModel.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error actualizando perfil: $e');
      _error = 'Error al actualizar perfil';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== COURSES ==========
  
  Future<void> loadCourses() async {
    try {
      print('📚 Loading courses...');
      final data = await _apiService.getAvailableCourses();
      
      _courses = data.map((json) {
        try {
          return CourseModel.fromJson(json);
        } catch (e) {
          print('❌ Error parsing course: $e');
          return _createFallbackCourse(json);
        }
      }).toList();

      print('✅ Courses loaded: ${_courses.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading courses: $e');
      _error = 'Error al cargar cursos';
      notifyListeners();
    }
  }

  Future<bool> enrollInCourse(int courseId) async {
    try {
      await _apiService.enrollCourse(courseId);
      await loadCourses();
      await loadProgress();
      return true;
    } catch (e) {
      _error = 'Error al inscribirse en el curso';
      notifyListeners();
      print('❌ Error en enrollInCourse: $e');
      return false;
    }
  }

  Future<bool> createCourse({
    required String title,
    required String description,
    String? difficulty,
    int? levelRequired,
  }) async {
    if (!canManage) {
      _error = 'No tienes permisos para crear cursos';
      notifyListeners();
      return false;
    }

    try {
      await _apiService.createCourse(
        title: title,
        description: description,
        difficulty: difficulty,
        levelRequired: levelRequired,
      );
      await loadCourses();
      return true;
    } catch (e) {
      _error = 'Error al crear curso';
      notifyListeners();
      print('❌ Error en createCourse: $e');
      return false;
    }
  }

  // ========== QUIZZES ==========
  
  Future<void> loadQuizzes() async {
    try {
      print('📝 Loading quizzes...');
      final data = await _apiService.getAvailableQuizzes();
      
      _quizzes = data.map((json) {
        try {
          return QuizModel.fromJson(json);
        } catch (e) {
          print('❌ Error parsing quiz: $e');
          return _createFallbackQuiz(json);
        }
      }).toList();

      print('✅ Quizzes loaded: ${_quizzes.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading quizzes: $e');
      _error = 'Error al cargar quizzes';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> submitQuiz({
    required int quizId,
    required Map<String, String> answers,
    required int timeTaken,
  }) async {
    try {
      final result = await _apiService.submitQuiz(
        quizId: quizId,
        answers: answers,
        timeTaken: timeTaken,
      );

      // Actualizar nivel y XP del usuario si cambió
      if (result.containsKey('current_level')) {
        _user = UserModel.fromJson({
          ..._apiService.userData,
          'level': result['current_level'],
          'xp': result['total_xp'],
        });
      }

      await loadQuizzes();
      await loadProgress();
      notifyListeners();

      return result;
    } catch (e) {
      _error = 'Error al enviar quiz';
      notifyListeners();
      print('❌ Error en submitQuiz: $e');
      return null;
    }
  }

  Future<void> loadQuizAttempts() async {
    try {
      print('📊 Loading quiz attempts...');
      final data = await _apiService.getMyQuizAttempts();
      
      _quizAttempts = data.map((json) {
        try {
          return QuizAttemptModel.fromJson(json);
        } catch (e) {
          print('❌ Error parsing quiz attempt: $e');
          return _createFallbackAttempt(json);
        }
      }).toList();

      print('✅ Quiz attempts loaded: ${_quizAttempts.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading quiz attempts: $e');
    }
  }

  Future<bool> createQuiz({
    required int courseId,
    required String title,
    required String description,
    String difficulty = 'medium',
    double passingScore = 70.0,
    int xpReward = 50,
    int timeLimit = 10,
    int maxAttempts = 3,
    List<Map<String, dynamic>>? questions,
  }) async {
    if (!canManage) {
      _error = 'No tienes permisos para crear quizzes';
      notifyListeners();
      return false;
    }

    try {
      await _apiService.createQuiz(
        courseId: courseId,
        title: title,
        description: description,
        difficulty: difficulty,
        passingScore: passingScore,
        xpReward: xpReward,
        timeLimit: timeLimit,
        maxAttempts: maxAttempts,
        questions: questions,
      );
      await loadQuizzes();
      return true;
    } catch (e) {
      _error = 'Error al crear quiz';
      notifyListeners();
      print('❌ Error en createQuiz: $e');
      return false;
    }
  }

  // ========== PROGRESS ==========
  
  Future<void> loadProgress() async {
    try {
      print('📈 Loading progress...');
      final data = await _apiService.getProgress();
      
      _progress = data.map((json) {
        try {
          return ProgressModel.fromJson(json);
        } catch (e) {
          print('❌ Error parsing progress: $e');
          return _createFallbackProgress(json);
        }
      }).toList();

      print('✅ Progress loaded: ${_progress.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading progress: $e');
      _error = 'Error al cargar progreso';
      notifyListeners();
    }
  }

  // ========== NOTIFICATIONS ==========
  
  Future<void> loadNotifications() async {
    try {
      print('🔔 Loading notifications...');
      final data = await _apiService.getNotifications();
      
      _notifications = data.map<NotificationModel>((json) {
        try {
          return NotificationModel.fromJson(json);
        } catch (e) {
          print('❌ Error parsing notification: $e');
          return _createFallbackNotification(json);
        }
      }).toList();

      _unreadNotificationsCount = _notifications.where((n) => !n.isRead).length;
      
      print('✅ Notifications loaded: ${_notifications.length} (${_unreadNotificationsCount} unread)');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();
      await loadNotifications();
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  // ========== LEADERBOARD ==========
  
  Future<List<dynamic>> getLeaderboard() async {
    try {
      return await _apiService.getLeaderboard();
    } catch (e) {
      _error = 'Error al cargar clasificación';
      notifyListeners();
      print('❌ Error en getLeaderboard: $e');
      return [];
    }
  }

  // ========== USUARIOS (Admin) ==========
  
  Future<List<dynamic>> getAllUsers() async {
    if (!isAdmin) {
      _error = 'No tienes permisos para ver usuarios';
      notifyListeners();
      return [];
    }

    try {
      return await _apiService.getAllUsers();
    } catch (e) {
      _error = 'Error al cargar usuarios';
      notifyListeners();
      print('❌ Error en getAllUsers: $e');
      return [];
    }
  }

  // ========== UTILIDADES ==========
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ========== FALLBACK CREATORS ==========
  
  CourseModel _createFallbackCourse(Map<String, dynamic> json) {
    return CourseModel(
      id: _parseInt(json['id']) ?? 0,
      title: _parseString(json['title']) ?? 'Curso sin título',
      description: _parseString(json['description']) ?? 'Sin descripción',
      levelRequired: _parseInt(json['level_required']) ?? 1,
      isActive: json['is_active'] ?? true,
      thumbnail: json['thumbnail'],
      estimatedDuration: _parseInt(json['estimated_duration']) ?? 60,
      difficulty: _parseString(json['difficulty']) ?? 'beginner',
      createdBy: _parseInt(json['created_by']) ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      enrolledStudentsCount: _parseInt(json['enrolled_students_count']) ?? _parseInt(json['enrolled_users_count']) ?? 0,
      completedStudentsCount: _parseInt(json['completed_students_count']) ?? _parseInt(json['completed_users_count']) ?? 0,
      quizCount: _parseInt(json['quiz_count']) ?? 0,
      isEnrolled: json['is_enrolled'] ?? false,
      userProgress: (json['user_progress'] ?? 0.0).toDouble(),
    );
  }

  QuizModel _createFallbackQuiz(Map<String, dynamic> json) {
    return QuizModel(
      id: _parseInt(json['id']) ?? 0,
      title: _parseString(json['title']) ?? 'Quiz sin título',
      description: _parseString(json['description']) ?? 'Sin descripción',
      course: _parseInt(json['course']) ?? 0,
      courseTitle: _parseString(json['course_title']) ?? '',
      difficulty: _parseString(json['difficulty']) ?? 'medium',
      passingScore: _parseDouble(json['passing_score']) ?? 70.0,
      xpReward: _parseInt(json['xp_reward']) ?? 50,
      timeLimit: _parseInt(json['time_limit']) ?? 10,
      isActive: json['is_active'] ?? true,
      maxAttempts: _parseInt(json['max_attempts']) ?? 3,
      createdBy: _parseInt(json['created_by']) ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  ProgressModel _createFallbackProgress(Map<String, dynamic> json) {
    return ProgressModel(
      id: _parseInt(json['id']) ?? 0,
      course: _parseInt(json['course']) ?? 0,
      courseTitle: _parseString(json['course_title']) ?? _parseString(json['course_name']) ?? 'Curso sin nombre',
      courseDifficulty: _parseString(json['course_difficulty']) ?? 'beginner',
      completedQuizzes: _parseInt(json['completed_quizzes']) ?? 0,
      totalQuizzes: _parseInt(json['total_quizzes']) ?? 0,
      remainingQuizzes: _parseInt(json['remaining_quizzes']) ?? 0,
      percentage: _parseDouble(json['percentage']) ?? _parseDouble(json['completion_percentage']) ?? 0.0,
      xpEarned: _parseInt(json['xp_earned']) ?? 0,
      courseCompleted: json['course_completed'] ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      streakDays: _parseInt(json['streak_days']) ?? 0,
      estimatedCompletionTime: json['estimated_completion_time'] != null ? (json['estimated_completion_time']).toDouble() : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  QuizAttemptModel _createFallbackAttempt(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: _parseInt(json['id']) ?? 0,
      quiz: _parseInt(json['quiz']) ?? 0,
      quizTitle: _parseString(json['quiz_title']) ?? '',
      courseTitle: _parseString(json['course_title']) ?? '',
      score: _parseDouble(json['score']) ?? 0.0,
      passed: json['passed'] ?? false,
      timeTaken: _parseInt(json['time_taken']) ?? 0,
      answers: json['answers'] ?? {},
      attemptNumber: _parseInt(json['attempt_number']) ?? 1,
      canRetake: json['can_retake'] ?? false,
      completedAt: DateTime.parse(json['completed_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  NotificationModel _createFallbackNotification(Map<String, dynamic> json) {
    return NotificationModel(
      id: _parseInt(json['id']) ?? 0,
      title: _parseString(json['title']) ?? 'Notificación',
      message: _parseString(json['message']) ?? '',
      type: _parseString(json['type']) ?? 'system',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      relatedCourseId: _parseInt(json['related_course_id']),
      relatedQuizId: _parseInt(json['related_quiz_id']),
    );
  }

  // ========== HELPERS ==========
  
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}