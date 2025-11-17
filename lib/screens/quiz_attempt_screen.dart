import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../models/quiz_model.dart';
import 'dart:async';

class QuizAttemptScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizAttemptScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {}; // question_id: answer
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<QuestionModel> _questions = [];
  Timer? _timer;
  int _timeElapsed = 0; // en segundos

  @override
  void initState() {
    super.initState();
    _loadQuizQuestions();
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
        setState(() {
          _timeElapsed++;
        });
      }
    });
  }

  Future<void> _loadQuizQuestions() async {
    try {
      final provider = context.read<AppProvider>();
      final quizData = await provider.apiService.getQuizDetail(widget.quiz.id);
      
      if (mounted) {
        setState(() {
          if (quizData['questions'] != null) {
            _questions = (quizData['questions'] as List)
                .map((q) => QuestionModel.fromJson(q))
                .toList();
          } else {
            _questions = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando preguntas: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar las preguntas: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
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
    _timer?.cancel();

    // Enviar respuestas al backend
    final provider = context.read<AppProvider>();
    final result = await provider.submitQuiz(
      quizId: widget.quiz.id,
      answers: _answers,
      timeTaken: _timeElapsed,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null) {
      final attempt = QuizAttemptModel.fromJson(result['attempt'] ?? result);
      _showResultDialog(
        score: attempt.score,
        passed: attempt.passed,
        xpGained: result['xp_gained'] ?? 0,
        newLevel: result['current_level'],
        detailedAnswers: attempt.answers,
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showResultDialog({
    required double score,
    required bool passed,
    required int xpGained,
    int? newLevel,
    Map<String, dynamic>? detailedAnswers,
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
              'Tu puntaje: ${score.toStringAsFixed(1)}%',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              passed
                  ? 'Has aprobado el quiz'
                  : 'Puntaje mínimo: ${widget.quiz.passingScore.toStringAsFixed(0)}%',
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
            if (detailedAnswers != null && detailedAnswers.isNotEmpty) ...[
              const SizedBox(height: AppStyles.spacingL),
              Text(
                'Revisión de respuestas',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppStyles.spacingM),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(_questions.length, (index) {
                      final question = _questions[index];
                      final questionId = question.id.toString();
                      final answerData = detailedAnswers[questionId];
                      if (answerData == null) return const SizedBox.shrink();
                      
                      final isCorrect = answerData['is_correct'] ?? false;
                      final userAnswer = answerData['user_answer'] ?? '';
                      final correctAnswer = answerData['correct_answer'] ?? '';
                      final explanation = answerData['explanation'] ?? '';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppStyles.spacingM),
                        padding: AppStyles.cardPadding,
                        decoration: BoxDecoration(
                          color: (isCorrect
                                  ? AppColors.successGreen
                                  : AppColors.errorRed)
                              .withOpacity(0.1),
                          borderRadius: AppStyles.standardBorderRadius,
                          border: Border.all(
                            color: isCorrect
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: isCorrect
                                      ? AppColors.successGreen
                                      : AppColors.errorRed,
                                  size: 20,
                                ),
                                const SizedBox(width: AppStyles.spacingS),
                                Expanded(
                                  child: Text(
                                    question.text,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppStyles.spacingS),
                            Text(
                              'Tu respuesta: $userAnswer',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.lightText,
                              ),
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Respuesta correcta: $correctAnswer',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (explanation.isNotEmpty) ...[
                              const SizedBox(height: AppStyles.spacingS),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundGray,
                                  borderRadius: AppStyles.smallBorderRadius,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      size: 16,
                                      color: AppColors.primaryOrange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        explanation,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text(widget.quiz.title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Text(widget.quiz.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
              const SizedBox(height: 16),
              Text(
                'No se pudieron cargar las preguntas',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppStyles.primaryButton,
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

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
                      if (widget.quiz.hasTimeLimit)
                        Text(
                          'Tiempo: ${_formatTime(_timeElapsed)}',
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
                        question.text,
                        style: AppTextStyles.h4,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingL),
                    ...List.generate(
                      question.options.length,
                      (index) {
                        final option = question.options[index];
                        final isSelected =
                            _answers[question.id.toString()] == option;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppStyles.spacingM),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _answers[question.id.toString()] = option;
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
