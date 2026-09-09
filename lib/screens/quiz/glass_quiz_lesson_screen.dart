import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../models/quiz_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_sheet.dart';
import '../../widgets/common/glass_icon_badge.dart';
import '../../widgets/common/native_audio_button.dart';

class GlassQuizLessonScreen extends StatefulWidget {
  final QuizModel quiz;

  const GlassQuizLessonScreen({super.key, required this.quiz});

  @override
  State<GlassQuizLessonScreen> createState() => _GlassQuizLessonScreenState();
}

class _GlassQuizLessonScreenState extends State<GlassQuizLessonScreen> {
  int _currentIndex = 0;
  final Map<String, String> _answers = {}; // question_id: answer
  String? _selectedOption;
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<QuestionModel> _questions = [];
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final provider = context.read<AppProvider>();
      final quizData = await provider.apiService.getQuizDetail(widget.quiz.id);

      if (mounted) {
        setState(() {
          if (quizData['questions'] != null && quizData['questions'] is List) {
            _questions = (quizData['questions'] as List)
                .map((q) => QuestionModel.fromJson(q))
                .toList();
          } else {
            _questions = widget.quiz.questions;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading questions: $e');
      if (mounted) {
        setState(() {
          _questions = widget.quiz.questions;
          _isLoading = false;
        });
      }
    }
  }

  void _onOptionSelected(String option) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedOption = option;
      final qId = _questions[_currentIndex].id.toString();
      _answers[qId] = option;
    });
  }

  void _checkAnswerAndProceed() {
    if (_selectedOption == null) return;

    final currentQuestion = _questions[_currentIndex];
    final isLast = _currentIndex == _questions.length - 1;

    // Abrir bottom sheet interactivo de verificación (Estilo Duolingo Glass)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determinación de corrección si el modelo trae la solución
    final bool? isCorrect = currentQuestion.correctOption != null
        ? currentQuestion.correctOption == _selectedOption
        : null;

    HapticFeedback.mediumImpact();

    GlassSheet.show(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
        final correct = isCorrect ?? true;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (correct ? AppColors.successGreen : AppColors.errorRed)
                        .withOpacity(0.2),
                  ),
                  child: Icon(
                    correct
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: correct
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  correct ? '¡Respuesta Registrada!' : '¡Solución Incorrecta!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: correct
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (currentQuestion.explanation != null &&
                currentQuestion.explanation!.isNotEmpty) ...[
              Text(
                currentQuestion.explanation!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
            ],
            GlassButton(
              text: isLast ? 'Finalizar Lección' : 'Continuar',
              icon: Icons.arrow_forward_rounded,
              variant: correct
                  ? GlassButtonVariant.primary
                  : GlassButtonVariant.secondary,
              onPressed: () {
                Navigator.pop(ctx);
                if (isLast) {
                  _submitQuiz();
                } else {
                  setState(() {
                    _currentIndex++;
                    _selectedOption = _answers[_questions[_currentIndex].id.toString()];
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitQuiz() async {
    setState(() => _isSubmitting = true);
    _timer?.cancel();

    final provider = context.read<AppProvider>();
    final result = await provider.submitQuiz(
      quizId: widget.quiz.id,
      answers: _answers,
      timeTaken: _secondsElapsed,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null) {
      final score = (result['score'] ?? result['attempt']?['score'] ?? 0.0).toDouble();
      final passed = result['passed'] ?? result['attempt']?['passed'] ?? (score >= widget.quiz.passingScore);
      final xpGained = result['xp_earned'] ?? result['xp_gained'] ?? widget.quiz.xpReward;
      final newLevel = result['current_level'] ?? result['new_level'];

      _showCelebrationSheet(
        score: score,
        passed: passed,
        xpGained: xpGained,
        newLevel: newLevel,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar la lección. Revisa tu conexión.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showCelebrationSheet({
    required double score,
    required bool passed,
    required int xpGained,
    int? newLevel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    GlassSheet.show(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassIconBadge(
            icon: passed ? AppIcons.celebrate : AppIcons.speed,
            color: passed ? AppIcons.successColor : AppIcons.streakColor,
            size: 72,
            iconSize: 36,
            borderRadius: 36,
          ),
          const SizedBox(height: 16),
          Text(
            passed ? '¡Lección Completada!' : '¡Sigue Practicando!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Puntaje: ${score.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Recompensa en cristal (XP + Racha)
          GlassContainer(
            borderRadius: BorderRadius.circular(16),
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.xp, color: AppIcons.xpColor, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      '+$xpGained XP',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(AppIcons.streak, color: AppIcons.streakColor, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Racha Activa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (newLevel != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.level, color: AppColors.primaryOrange, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '¡Has subido al Nivel $newLevel!',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          GlassButton(
            text: 'Continuar',
            icon: Icons.check_rounded,
            onPressed: () {
              Navigator.pop(sheetCtx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return GlassBackground(
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return GlassBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: Text(widget.quiz.title)),
          body: Center(
            child: GlassCard(
              margin: const EdgeInsets.all(24),
              child: const Text(
                'Esta lección aún no contiene preguntas disponibles.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior minimalista
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _showExitConfirmation();
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.black.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${_currentIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),

              // Cuerpo: Tarjeta de pregunta y opciones
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tarjeta de la Pregunta en Cristal
                      GlassCard(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'WAYUUNAIKI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                // Botón de audio nativo si la pregunta tiene pronunciación
                                if (currentQuestion.audio != null)
                                  NativeAudioButton(
                                    audioUrl: currentQuestion.audio,
                                    size: 40,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              currentQuestion.text,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                                color: isDark ? Colors.white : AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Opciones de respuesta
                      ..._buildOptions(currentQuestion, isDark),
                    ],
                  ),
                ),
              ),

              // Botón inferior fijo: Comprobar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: GlassButton(
                  text: 'COMPROBAR',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _selectedOption != null
                      ? () => _checkAnswerAndProceed()
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(QuestionModel question, bool isDark) {
    if (question.options.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay opciones disponibles para esta pregunta.'),
        ),
      ];
    }

    return question.options.map((option) {
      final isSelected = _selectedOption == option;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          borderRadius: BorderRadius.circular(18),
          backgroundColor: isSelected
              ? AppColors.primaryOrange.withOpacity(isDark ? 0.35 : 0.20)
              : null,
          borderGradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryOrange,
                    AppColors.primaryOrange.withOpacity(0.4),
                  ],
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          onTap: () => _onOptionSelected(option),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : (isDark ? Colors.white30 : Colors.black26),
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : AppColors.primaryOrange)
                        : (isDark ? Colors.white : AppColors.darkText),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Deseas salir?'),
        content: const Text(
          'Si abandonas ahora, el progreso de esta lección no se guardará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar aprendiendo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
