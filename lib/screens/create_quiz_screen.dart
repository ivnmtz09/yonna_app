import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  
  int? _selectedCourseId;
  String _difficulty = 'medium';
  double _passingScore = 70.0;
  int _xpReward = 50;
  int _timeLimit = 10;
  int _maxAttempts = 3;
  
  bool _isLoading = false;
  final List<QuestionFormData> _questions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    for (var q in _questions) {
      q.textCtrl.dispose();
      for (var opt in q.optionsCtrls) {
        opt.dispose();
      }
      q.correctAnswerCtrl?.dispose();
      q.explanationCtrl?.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionFormData(
        order: _questions.length + 1,
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index].textCtrl.dispose();
      for (var opt in _questions[index].optionsCtrls) {
        opt.dispose();
      }
      _questions[index].correctAnswerCtrl?.dispose();
      _questions[index].explanationCtrl?.dispose();
      _questions.removeAt(index);
      // Reordenar
      for (int i = 0; i < _questions.length; i++) {
        _questions[i].order = i + 1;
      }
    });
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un curso'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos una pregunta'),
          backgroundColor: AppColors.warningYellow,
        ),
      );
      return;
    }

    // Validar todas las preguntas
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.textCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La pregunta ${i + 1} debe tener texto'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      if (q.questionType == 'multiple_choice' || q.questionType == 'true_false') {
        if (q.optionsCtrls.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La pregunta ${i + 1} debe tener al menos 2 opciones'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }

        final options = q.optionsCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
        if (options.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La pregunta ${i + 1} debe tener al menos 2 opciones válidas'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }

        if (q.correctAnswerCtrl?.text.trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La pregunta ${i + 1} debe tener una respuesta correcta'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
      } else if (q.questionType == 'short_answer') {
        if (q.correctAnswerCtrl?.text.trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La pregunta ${i + 1} debe tener una respuesta correcta'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();

    try {
      // Preparar preguntas para el backend
      final questionsData = _questions.map((q) {
        final questionData = <String, dynamic>{
          'text': q.textCtrl.text.trim(),
          'question_type': q.questionType,
          'order': q.order,
        };

        if (q.questionType == 'multiple_choice' || q.questionType == 'true_false') {
          questionData['options'] = q.optionsCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList();
          questionData['correct_answer'] = q.correctAnswerCtrl!.text.trim();
        } else {
          questionData['options'] = [];
          questionData['correct_answer'] = q.correctAnswerCtrl!.text.trim();
        }

        if (q.explanationCtrl?.text.trim().isNotEmpty ?? false) {
          questionData['explanation'] = q.explanationCtrl!.text.trim();
        }

        return questionData;
      }).toList();

      await provider.apiService.createQuiz(
        courseId: _selectedCourseId!,
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        difficulty: _difficulty,
        passingScore: _passingScore,
        xpReward: _xpReward,
        timeLimit: _timeLimit,
        maxAttempts: _maxAttempts,
        questions: questionsData,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz creado exitosamente'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear quiz: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Crear Quiz'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppStyles.screenPadding,
          children: [
            // Header
            Container(
              padding: AppStyles.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: AppStyles.standardBorderRadius,
                border: Border.all(
                  color: AppColors.accentGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    color: AppColors.accentGreen,
                    size: 32,
                  ),
                  const SizedBox(width: AppStyles.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo Quiz',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crea una evaluación para tus estudiantes',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppStyles.spacingL),

            // Información básica
            Text('Información del quiz', style: AppTextStyles.h4),
            const SizedBox(height: AppStyles.spacingM),

            // Selector de curso
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                if (provider.courses.isEmpty) {
                  return Container(
                    padding: AppStyles.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.warningYellow.withOpacity(0.1),
                      borderRadius: AppStyles.standardBorderRadius,
                    ),
                    child: const Text(
                      'Primero debes crear un curso',
                      style: TextStyle(color: AppColors.warningYellow),
                    ),
                  );
                }

                return DropdownButtonFormField<int>(
                  decoration: AppStyles.inputDecoration(
                    labelText: 'Curso',
                    icon: Icons.school_outlined,
                  ),
                  value: _selectedCourseId,
                  items: provider.courses.map((course) {
                    return DropdownMenuItem(
                      value: course.id,
                      child: Text(course.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCourseId = value);
                  },
                  validator: (v) => v == null ? 'Selecciona un curso' : null,
                );
              },
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Título
            TextFormField(
              controller: _titleCtrl,
              decoration: AppStyles.inputDecoration(
                labelText: 'Título del quiz',
                icon: Icons.title,
                hintText: 'Ej: Vocabulario Básico',
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingrese un título' : null,
              maxLength: 100,
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Descripción
            TextFormField(
              controller: _descriptionCtrl,
              decoration: AppStyles.inputDecoration(
                labelText: 'Descripción',
                icon: Icons.description_outlined,
                hintText: 'Describe el contenido del quiz',
              ),
              maxLines: 3,
              maxLength: 300,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingrese una descripción' : null,
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Configuración del quiz
            Text('Configuración', style: AppTextStyles.h4),
            const SizedBox(height: AppStyles.spacingM),

            // Dificultad
            DropdownButtonFormField<String>(
              decoration: AppStyles.inputDecoration(
                labelText: 'Dificultad',
                icon: Icons.trending_up,
              ),
              value: _difficulty,
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Fácil')),
                DropdownMenuItem(value: 'medium', child: Text('Medio')),
                DropdownMenuItem(value: 'hard', child: Text('Difícil')),
              ],
              onChanged: (value) {
                setState(() => _difficulty = value!);
              },
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Puntaje mínimo
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _passingScore.toString(),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Puntaje mínimo (%)',
                      icon: Icons.check_circle_outline,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      _passingScore = double.tryParse(v) ?? 70.0;
                    },
                  ),
                ),
                const SizedBox(width: AppStyles.spacingM),
                Expanded(
                  child: TextFormField(
                    initialValue: _xpReward.toString(),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'XP Recompensa',
                      icon: Icons.star,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      _xpReward = int.tryParse(v) ?? 50;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Tiempo límite y intentos
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _timeLimit.toString(),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Tiempo límite (min)',
                      icon: Icons.timer,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      _timeLimit = int.tryParse(v) ?? 10;
                    },
                  ),
                ),
                const SizedBox(width: AppStyles.spacingM),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxAttempts.toString(),
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Intentos máximos',
                      icon: Icons.repeat,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      _maxAttempts = int.tryParse(v) ?? 3;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingXL),

            // Preguntas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Preguntas (${_questions.length})', style: AppTextStyles.h4),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.whiteText,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),

            // Lista de preguntas
            ...List.generate(_questions.length, (index) {
              return _buildQuestionCard(_questions[index], index);
            }),

            if (_questions.isEmpty)
              Container(
                padding: AppStyles.cardPadding,
                decoration: AppStyles.cardDecoration,
                child: Column(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 48,
                      color: AppColors.lightText.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppStyles.spacingM),
                    Text(
                      'No hay preguntas agregadas',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingS),
                    Text(
                      'Agrega al menos una pregunta para crear el quiz',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.lightText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppStyles.spacingXL),

            // Botones de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createQuiz,
                style: AppStyles.primaryButton,
                child: _isLoading
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
                    : const Text('Crear Quiz'),
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: AppStyles.outlinedButton,
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionFormData question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingM),
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de pregunta
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: AppStyles.smallBorderRadius,
                ),
                child: Text(
                  'Pregunta ${question.order}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                onPressed: () => _removeQuestion(index),
                tooltip: 'Eliminar pregunta',
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),

          // Tipo de pregunta
          DropdownButtonFormField<String>(
            decoration: AppStyles.inputDecoration(
              labelText: 'Tipo de pregunta',
              icon: Icons.quiz,
            ),
            value: question.questionType,
            items: const [
              DropdownMenuItem(
                value: 'multiple_choice',
                child: Text('Opción múltiple'),
              ),
              DropdownMenuItem(
                value: 'true_false',
                child: Text('Verdadero/Falso'),
              ),
              DropdownMenuItem(
                value: 'short_answer',
                child: Text('Respuesta corta'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                question.questionType = value!;
                // Si cambia a true_false, agregar opciones automáticamente
                if (value == 'true_false' && question.optionsCtrls.isEmpty) {
                  question.optionsCtrls = [
                    TextEditingController(text: 'Verdadero'),
                    TextEditingController(text: 'Falso'),
                  ];
                }
              });
            },
          ),
          const SizedBox(height: AppStyles.spacingM),

          // Texto de la pregunta
          TextFormField(
            controller: question.textCtrl,
            decoration: AppStyles.inputDecoration(
              labelText: 'Texto de la pregunta',
              icon: Icons.question_answer,
              hintText: 'Ej: ¿Cómo se dice "Hola" en Wayuunaiki?',
            ),
            maxLines: 2,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingrese el texto de la pregunta' : null,
          ),
          const SizedBox(height: AppStyles.spacingM),

          // Opciones (solo para multiple_choice y true_false)
          if (question.questionType == 'multiple_choice' ||
              question.questionType == 'true_false') ...[
            Text(
              'Opciones de respuesta',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            ...List.generate(question.optionsCtrls.length, (optIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppStyles.spacingS),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: question.optionsCtrls[optIndex],
                        decoration: AppStyles.inputDecoration(
                          labelText: 'Opción ${optIndex + 1}',
                          hintText: 'Escribe una opción',
                        ),
                      ),
                    ),
                    if (question.optionsCtrls.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppColors.errorRed),
                        onPressed: () {
                          setState(() {
                            question.optionsCtrls[optIndex].dispose();
                            question.optionsCtrls.removeAt(optIndex);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  question.optionsCtrls.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Agregar opción'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),
          ],

          // Respuesta correcta
          TextFormField(
            controller: question.correctAnswerCtrl,
            decoration: AppStyles.inputDecoration(
              labelText: question.questionType == 'short_answer'
                  ? 'Respuesta correcta'
                  : 'Respuesta correcta (debe coincidir exactamente)',
              icon: Icons.check_circle,
              hintText: question.questionType == 'short_answer'
                  ? 'Ej: wüin'
                  : 'Escribe la respuesta correcta',
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingrese la respuesta correcta' : null,
          ),
          const SizedBox(height: AppStyles.spacingM),

          // Explicación (opcional)
          TextFormField(
            controller: question.explanationCtrl,
            decoration: AppStyles.inputDecoration(
              labelText: 'Explicación (opcional)',
              icon: Icons.lightbulb_outline,
              hintText: 'Explica por qué esta es la respuesta correcta',
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// Clase auxiliar para manejar datos de preguntas en el formulario
class QuestionFormData {
  int order;
  String questionType;
  TextEditingController textCtrl;
  List<TextEditingController> optionsCtrls;
  TextEditingController? correctAnswerCtrl;
  TextEditingController? explanationCtrl;

  QuestionFormData({
    required this.order,
    this.questionType = 'multiple_choice',
  })  : textCtrl = TextEditingController(),
        optionsCtrls = questionType == 'true_false'
            ? [
                TextEditingController(text: 'Verdadero'),
                TextEditingController(text: 'Falso'),
              ]
            : [
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
              ],
        correctAnswerCtrl = TextEditingController(),
        explanationCtrl = TextEditingController();
}
