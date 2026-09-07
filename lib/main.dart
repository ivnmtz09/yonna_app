import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yonna_app/services/api_service.dart';
import 'package:yonna_app/providers/app_provider.dart';
import 'package:yonna_app/providers/theme_provider.dart';
import 'package:yonna_app/theme/app_theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/shell_navigation_screen.dart';
import 'screens/enhanced_home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/quizzes_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/create_course_screen.dart';
import 'screens/create_quiz_screen.dart';
import 'screens/quiz/glass_quiz_lesson_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/manage_users_screen.dart';
import 'screens/admin_stats_screen.dart';
import 'models/quiz_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar ApiService
  await ApiService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Yonna Akademia',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              // Experiencia Principal Glassmorphic Duolingo (Shell Navigation)
              '/home': (context) => const ShellNavigationScreen(),
              '/shell': (context) => const ShellNavigationScreen(),
              '/learning-path': (context) => const ShellNavigationScreen(initialTab: 0),
              '/vocabulary': (context) => const ShellNavigationScreen(initialTab: 1),
              '/leaderboard': (context) => const ShellNavigationScreen(initialTab: 2),
              '/media': (context) => const ShellNavigationScreen(initialTab: 3),
              '/profile': (context) => const ShellNavigationScreen(initialTab: 4),
              // Vistas auxiliares y administrativas
              '/enhanced-home': (context) => const EnhancedHomeScreen(),
              '/old-profile': (context) => const ProfileScreen(),
              '/edit-profile': (context) => const EditProfileScreen(),
              '/courses': (context) => const CoursesScreen(),
              '/quizzes': (context) => const QuizzesScreen(),
              '/progress': (context) => const ProgressScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/create-course': (context) => const CreateCourseScreen(),
              '/create-quiz': (context) => const CreateQuizScreen(),
              '/manage-users': (context) => const ManageUsersScreen(),
              '/admin-stats': (context) => const AdminStatsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/quiz-attempt') {
                final quiz = settings.arguments;
                if (quiz is QuizModel) {
                  return MaterialPageRoute(
                    builder: (_) => GlassQuizLessonScreen(quiz: quiz),
                  );
                }
              }
              return null;
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
