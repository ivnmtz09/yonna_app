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
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/welcome':
              return MaterialPageRoute(builder: (_) => const WelcomeScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/home':
              return MaterialPageRoute(
                  builder: (_) => const EnhancedHomeScreen());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/edit-profile':
              return MaterialPageRoute(
                  builder: (_) => const EditProfileScreen());
            case '/courses':
              return MaterialPageRoute(builder: (_) => const CoursesScreen());
            case '/quizzes':
              return MaterialPageRoute(builder: (_) => const QuizzesScreen());
            case '/progress':
              return MaterialPageRoute(builder: (_) => const ProgressScreen());
            case '/notifications':
              return MaterialPageRoute(
                  builder: (_) => const NotificationsScreen());
            case '/create-course':
              return MaterialPageRoute(
                  builder: (_) => const CreateCourseScreen());
            case '/create-quiz':
              return MaterialPageRoute(
                  builder: (_) => const CreateQuizScreen());
            case '/quiz-attempt':
              final quiz = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => QuizAttemptScreen(quiz: quiz),
              );
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },
      ),
    );
  }
}
