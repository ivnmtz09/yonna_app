import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yonna_app/services/api_service.dart';
import 'package:yonna_app/providers/app_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/enhanced_home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/quizzes_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/create_course_screen.dart';
import 'screens/create_quiz_screen.dart';
import 'screens/quiz_attempt_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/manage_users_screen.dart';
import 'screens/admin_stats_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'models/quiz_model.dart';

// Styles
import 'widgets/app_styles.dart';

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
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Yonna Akademia',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundGray,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.whiteText,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteText,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryOrange,
            primary: AppColors.primaryOrange,
            secondary: AppColors.primaryBlue,
            background: AppColors.backgroundGray,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const EnhancedHomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/courses': (context) => const CoursesScreen(),
          '/quizzes': (context) => const QuizzesScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/create-course': (context) => const CreateCourseScreen(),
          '/create-quiz': (context) => const CreateQuizScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/manage-users': (context) => const ManageUsersScreen(),
          '/admin-stats': (context) => const AdminStatsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/quiz-attempt') {
            final quiz = settings.arguments;
            if (quiz is QuizModel) {
              return MaterialPageRoute(
                builder: (_) => QuizAttemptScreen(quiz: quiz),
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
      ),
    );
  }
}
