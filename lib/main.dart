import 'package:flutter/material.dart';
import 'package:yonna_app/services/api_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'widgets/app_styles.dart';

// Hacemos main asíncrono para poder inicializar servicios
Future<void> main() async {
  // Aseguramos que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // --- INICIALIZAMOS EL SERVICIO SINGLETON ---
  // Esto carga SharedPreferences antes de que la app corra
  await ApiService().init();
  // ------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yonna Akademia',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundWhite,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.backgroundWhite,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.backgroundWhite,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.accentOrange,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
