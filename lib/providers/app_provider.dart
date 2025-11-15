import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/quiz_model.dart';
import '../models/progress_model.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Exponer apiService para acceso directo
  ApiService get apiService => _apiService;

  // Estado del usuario
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Datos de cursos y quizzes
  List<CourseModel> _courses = [];
  List<QuizModel> _quizzes = [];
  List<ProgressModel> _progress = [];

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CourseModel> get courses => _courses;
  List<QuizModel> get quizzes => _quizzes;
  List<ProgressModel> get progress => _progress;

  bool get isAuthenticated => _user != null;
  bool get isTeacher => _user?.isTeacher ?? false;

  // --- INICIALIZACIÓN ---
  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_apiService.userData.isNotEmpty) {
        _user = UserModel.fromJson(_apiService.userData);
      } else {
        final data = await _apiService.getProfile();
        _user = UserModel.fromJson(data);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar datos del usuario';
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- AUTENTICACIÓN ---
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.login(email: email, password: password);

      if (data.containsKey('access')) {
        _user = UserModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = data['detail'] ?? 'Error al iniciar sesión';
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
    notifyListeners();
  }

  // --- CURSOS ---
  Future<void> loadCourses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _apiService.getAvailableCourses();
      _courses = data.map((json) => CourseModel.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar cursos';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enrollInCourse(int courseId) async {
    try {
      await _apiService.enrollCourse(courseId);
      await loadCourses(); // Recargar cursos
      await loadProgress(); // Actualizar progreso
      return true;
    } catch (e) {
      _error = 'Error al inscribirse';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createCourse(String title, String description) async {
    if (!isTeacher) {
      _error = 'Solo los sabedores pueden crear cursos';
      notifyListeners();
      return false;
    }

    try {
      await _apiService.createCourse(title: title, description: description);
      await loadCourses(); // Recargar cursos
      return true;
    } catch (e) {
      _error = 'Error al crear curso';
      notifyListeners();
      return false;
    }
  }

  // --- QUIZZES ---
  Future<void> loadQuizzes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _apiService.getAvailableQuizzes();
      _quizzes = data.map((json) => QuizModel.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar quizzes';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> submitQuizAttempt(int quizId, int score) async {
    try {
      final result = await _apiService.submitQuizAttempt(
        quizId: quizId,
        score: score,
      );

      // Actualizar XP y nivel del usuario si cambió
      if (result.containsKey('current_level')) {
        _user = UserModel.fromJson({
          ..._apiService.userData,
          'level': result['current_level'],
          'xp': result['total_xp'],
        });
      }

      await loadQuizzes(); // Recargar quizzes
      await loadProgress(); // Actualizar progreso
      notifyListeners();

      return result;
    } catch (e) {
      _error = 'Error al enviar resultado';
      notifyListeners();
      return null;
    }
  }

  // --- PROGRESO ---
  Future<void> loadProgress() async {
    try {
      final data = await _apiService.getProgress();
      _progress = data.map((json) => ProgressModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar progreso';
      notifyListeners();
    }
  }

  // --- PERFIL ---
  Future<bool> updateProfile({
    String? telefono,
    String? localidad,
    List<String>? gustos,
  }) async {
    try {
      final data = await _apiService.updateProfile(
        telefono: telefono,
        localidad: localidad,
        gustos: gustos,
      );

      _user = UserModel.fromJson(data);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar perfil';
      notifyListeners();
      return false;
    }
  }

  // --- UTILIDADES ---
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
