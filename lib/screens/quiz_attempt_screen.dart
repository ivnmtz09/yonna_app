import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import 'dart:math';

class QuizAttemptScreen extends StatefulWidget {
  final dynamic quiz;

  const QuizAttemptScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, String> _answers = {};
  bool _isSubmitting = false;

  // Preguntas de ejemplo (en producción vendrían del backend)
  late final List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _generateSampleQuestions();
  }

  List<Map<String, dynamic>> _generateSampleQuestions() {
    return List.generate(10, (index) {
      return {
        'id': index + 1,
        'question':
            'Pregunta ${index + 1}: ¿Cómo se dice "agua" en Wayuunaiki?',
        'options': [
          'Wüin',
          'Kashi',
          'Palaa',
          'Juyá',
        ]..shuffle(Random()),
        'correctAnswer': 'Wüin',
      };
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  Future<void> _submitQuiz() async {
    // Verificar que todas las preguntas estén respondidas
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas'),
          backgroundColor: AppColors.warningYellow,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Calcular puntaje
    int correctAnswers = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    final score = ((correctAnswers / _questions.length) * 100).round();

    // Enviar resultado al backend
    final provider = context.read<AppProvider>();
    final result = await provider.submitQuizAttempt(widget.quiz.id, score);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null) {
      _showResultDialog(
        score: score,
        passed: result['passed'] ?? false,
        xpGained: result['xp_gained'] ?? 0,
        newLevel: result['current_level'],
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar el quiz'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showResultDialog({
    required int score,
    required bool passed,
    required int xpGained,
    int? newLevel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppStyles.standardBorderRadius,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.celebration : Icons.sentiment_dissatisfied,
              color: passed ? AppColors.successGreen : AppColors.errorRed,
              size: 64,
            ),
            const SizedBox(height: AppStyles.spacingL),
            Text(
              passed ? '¡Felicidades!' : '¡Casi lo logras!',
              style: AppTextStyles.h2.copyWith(
                color: passed ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              'Tu puntaje: $score%',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              passed
                  ? 'Has aprobado el quiz'
                  : 'Puntaje mínimo: ${widget.quiz.passingScore}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightText,
              ),
            ),
            if (xpGained > 0) ...[
              const SizedBox(height: AppStyles.spacingL),
              Container(
                padding: AppStyles.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: AppStyles.standardBorderRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(width: AppStyles.spacingS),
                    Text(
                      '+$xpGained XP',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (newLevel != null &&
                newLevel > context.read<AppProvider>().user!.level) ...[
              const SizedBox(height: AppStyles.spacingM),
              Container(
                padding: AppStyles.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: AppStyles.standardBorderRadius,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppColors.successGreen,
                      size: 32,
                    ),
                    const SizedBox(height: AppStyles.spacingS),
                    Text(
                      '¡Subiste al nivel $newLevel!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!passed)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                setState(() {
                  _currentQuestionIndex = 0;
                  _answers.clear();
                });
              },
              child: const Text('Reintentar'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a quizzes
            },
            child: Text(passed ? 'Continuar' : 'Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir del quiz?'),
            content: const Text('Tu progreso se perderá si sales ahora'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salir'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text(widget.quiz.title),
        ),
        body: Column(
          children: [
            // Barra de progreso
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.backgroundWhite,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(_answers.length / _questions.length * 100).toStringAsFixed(0)}% respondido',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingS),
                  ClipRRect(
                    borderRadius: AppStyles.smallBorderRadius,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.backgroundGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pregunta y opciones
            Expanded(
              child: SingleChildScrollView(
                padding: AppStyles.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: AppStyles.cardPadding,
                      decoration: AppStyles.cardDecoration,
                      child: Text(
                        question['question'],
                        style: AppTextStyles.h4,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingL),
                    ...List.generate(
                      question['options'].length,
                      (index) {
                        final option = question['options'][index];
                        final isSelected =
                            _answers[_currentQuestionIndex] == option;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppStyles.spacingM),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _answers[_currentQuestionIndex] = option;
                              });
                            },
                            borderRadius: AppStyles.standardBorderRadius,
                            child: Container(
                              padding: AppStyles.cardPadding,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhite,
                                borderRadius: AppStyles.standardBorderRadius,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryOrange
                                      : AppColors.lightText.withOpacity(0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryOrange
                                            : AppColors.lightText,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? AppColors.primaryOrange
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: AppColors.whiteText,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppStyles.spacingM),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Botones de navegación
            Container(
              padding: AppStyles.screenPadding,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: AppStyles.outlinedButton,
                        child: const Text('Anterior'),
                      ),
                    ),
                  if (_currentQuestionIndex > 0)
                    const SizedBox(width: AppStyles.spacingM),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : (_currentQuestionIndex == _questions.length - 1
                              ? _submitQuiz
                              : _nextQuestion),
                      style: AppStyles.primaryButton,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.whiteText,
                                ),
                              ),
                            )
                          : Text(
                              _currentQuestionIndex == _questions.length - 1
                                  ? 'Enviar'
                                  : 'Siguiente',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
