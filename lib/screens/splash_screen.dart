import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_container.dart';
import 'shell_navigation_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _initVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAppInitialization();
      }
    });
  }

  Future<void> _initVideo() async {
    try {
      _videoController =
          VideoPlayerController.asset('assets/images/loading.mov');
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0.0);
      await _videoController!.play();
      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (e) {
      debugPrint('⚠️ No se pudo inicializar video de carga: $e');
    }
  }

  Future<void> _startAppInitialization() async {
    final provider = context.read<AppProvider>();

    try {
      await Future.wait([
        _progressController.forward(),
        provider.initializeApp().timeout(
          const Duration(seconds: 6),
          onTimeout: () {
            debugPrint('⚠️ Timeout al inicializar datos en Splash');
          },
        ),
      ]);
    } catch (e) {
      debugPrint('Error en inicialización de app: $e');
    }

    // Breve pausa para apreciar el 100% y dar un cierre suave
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    _navigateToNextScreen(provider.isAuthenticated);
  }

  void _navigateToNextScreen(bool isAuthenticated) {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    final Widget nextScreen = isAuthenticated
        ? const ShellNavigationScreen()
        : const WelcomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  String _getLoadingMessage(double progress) {
    if (progress < 0.35) {
      return 'Iniciando aventura...';
    } else if (progress < 0.70) {
      return 'Cargando Wayuunaiki...';
    } else if (progress < 0.95) {
      return 'Sincronizando sabiduría...';
    } else {
      return '¡Kojutko! Todo listo...';
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final cardWidth = math.min(size.width * 0.82, 320.0);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E17) : const Color(0xFFF8FAFC),
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header de Marca Yonna
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/icon.png',
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Yonna',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Aprende la lengua y cultura Wayuu',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.65)
                            : const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tarjeta Glassmorphic con el Video .mov en el Centro
                    GlassContainer(
                      width: cardWidth,
                      borderRadius: BorderRadius.circular(26),
                      borderWidth: 1.5,
                      padding: const EdgeInsets.all(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(
                            alpha: isDark ? 0.28 : 0.16,
                          ),
                          blurRadius: 36,
                          spreadRadius: -4,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.40 : 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _isVideoInitialized && _videoController != null
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio > 0
                                        ? _videoController!.value.aspectRatio
                                        : (16 / 9),
                                child: VideoPlayer(_videoController!),
                              )
                            : AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  color: isDark
                                      ? Colors.black26
                                      : Colors.white24,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/mascota.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/images/yonna.png',
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Barra de Progreso Glassmorphic justo debajo
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        final progress =
                            _progressAnimation.value.clamp(0.0, 1.0);
                        return Column(
                          children: [
                            // Pista de progreso de vidrio
                            Container(
                              width: cardWidth * 0.92,
                              height: 8,
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : Colors.black.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : Colors.black.withValues(alpha: 0.10),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.25 : 0.04,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primaryOrange,
                                          Color(0xFFFFB703),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryOrange
                                              .withValues(
                                            alpha: 0.55,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Mensaje dinámico y porcentaje
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getLoadingMessage(progress),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : const Color(0xFF475569),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}