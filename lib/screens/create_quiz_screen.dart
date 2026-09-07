import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_button.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';

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
      _questions.add(
        QuestionFormData(
          order: _questions.length + 1,
          questionType: 'multiple_choice',
          textCtrl: TextEditingController(),
          optionsCtrls: [
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
          ],
          correctAnswerCtrl: TextEditingController(),
          explanationCtrl: TextEditingController(),
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      final removed = _questions.removeAt(index);
      removed.textCtrl.dispose();
      for (var opt in removed.optionsCtrls) {
        opt.dispose();
      }
      removed.correctAnswerCtrl?.dispose();
      removed.explanationCtrl?.dispose();

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
          content: Text('Agrega al menos una pregunta al quiz'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.textCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La pregunta ${i + 1} no tiene enunciado'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      if (q.questionType == 'multiple_choice') {
        final filledOptions = q.optionsCtrls.where((c) => c.text.trim().isNotEmpty).toList();
        if (filledOptions.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La pregunta ${i + 1} debe tener al menos 2 opciones'),
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
      }
    }

    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();

    try {
      final questionsData = _questions.map((q) {
        final questionData = <String, dynamic>{
          'text': q.textCtrl.text.trim(),
          'question_type': q.questionType,
          'order': q.order,
        };

        if (q.questionType == 'multiple_choice' || q.questionType == 'true_false') {
          int optIdx = 0;
          questionData['options'] = q.optionsCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .map((optText) {
                final id = String.fromCharCode(97 + (optIdx++));
                final isCorrect = (optText.toLowerCase() == q.correctAnswerCtrl!.text.trim().toLowerCase());
                return {
                  'id': id,
                  'text': optText,
                  'is_correct': isCorrect,
                };
              })
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

      final success = await provider.createQuiz(
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

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz creado exitosamente'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al crear quiz'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior minimalista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(21),
                      child: GlassContainer(
                        width: 42,
                        height: 42,
                        borderRadius: BorderRadius.circular(21),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Nuevo Quiz de Evaluación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Parámetros Generales
                        GlassCard(
                          borderRadius: BorderRadius.circular(22),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CONFIGURACIÓN DEL QUIZ',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white60 : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Consumer<AppProvider>(
                                builder: (context, provider, child) {
                                  return DropdownButtonFormField<int>(
                                    dropdownColor: isDark ? const Color(0xFF1E2430) : Colors.white,
                                    style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
                                    decoration: _inputDeco('Curso Asociado', Icons.school_outlined, isDark),
                                    value: _selectedCourseId,
                                    items: provider.courses.map((course) {
                                      return DropdownMenuItem(
                                        value: course.id,
                                        child: Text(course.title),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(() => _selectedCourseId = val),
                                    validator: (v) => v == null ? 'Selecciona un curso' : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _titleCtrl,
                                style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
                                decoration: _inputDeco('Título del Quiz', Icons.title_rounded, isDark),
                                validator: (v) => (v == null || v.isEmpty) ? 'Ingresa un título' : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _descriptionCtrl,
                                maxLines: 2,
                                style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
                                decoration: _inputDeco('Descripción', Icons.description_outlined, isDark),
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      dropdownColor: isDark ? const Color(0xFF1E2430) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
                                      decoration: _inputDeco('Dificultad', Icons.speed_rounded, isDark),
                                      value: _difficulty,
                                      items: const [
                                        DropdownMenuItem(value: 'easy', child: Text('Fácil')),
                                        DropdownMenuItem(value: 'medium', child: Text('Medio')),
                                        DropdownMenuItem(value: 'hard', child: Text('Difícil')),
                                      ],
                                      onChanged: (v) => setState(() => _difficulty = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _xpReward.toString(),
                                      style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDeco('XP Recompensa', AppIcons.xp, isDark),
                                      onChanged: (v) => _xpReward = int.tryParse(v) ?? 50,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Preguntas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PREGUNTAS (${_questions.length})',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.white60 : AppColors.lightText,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addQuestion,
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primaryOrange),
                              label: const Text(
                                'Añadir Pregunta',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (_questions.isEmpty)
                          GlassCard(
                            borderRadius: BorderRadius.circular(20),
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.quiz_outlined, size: 40, color: isDark ? Colors.white30 : Colors.black26),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Añade al menos una pregunta para el quiz',
                                    style: TextStyle(color: isDark ? Colors.white54 : AppColors.lightText),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ...List.generate(_questions.length, (i) => _buildQuestionCard(_questions[i], i, isDark)),
                        const SizedBox(height: 24),

                        GlassButton(
                          text: 'PUBLICAR EVALUACIÓN',
                          icon: Icons.check_circle_rounded,
                          isPrimary: true,
                          isLoading: _isLoading,
                          height: 50,
                          width: double.infinity,
                          onPressed: _createQuiz,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionFormData question, int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pregunta ${question.order}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 20),
                  onPressed: () => _removeQuestion(index),
                ),
              ],
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: question.textCtrl,
              style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
              decoration: _inputDeco('Enunciado (ej: ¿Cómo se dice Agua?)', Icons.help_outline_rounded, isDark),
            ),
            const SizedBox(height: 12),

            Text(
              'Opciones de respuesta:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : AppColors.darkText),
            ),
            const SizedBox(height: 8),

            ...List.generate(question.optionsCtrls.length, (optIdx) {
              final letter = String.fromCharCode(65 + optIdx);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  controller: question.optionsCtrls[optIdx],
                  style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
                  decoration: InputDecoration(
                    labelText: 'Opción $letter',
                    labelStyle: TextStyle(color: isDark ? Colors.white54 : AppColors.lightText),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              );
            }),

            const SizedBox(height: 6),
            TextFormField(
              controller: question.correctAnswerCtrl,
              style: TextStyle(color: isDark ? Colors.white : AppColors.darkText),
              decoration: _inputDeco('Texto exacto de la respuesta correcta', Icons.check_circle_outline_rounded, isDark),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white60 : AppColors.lightText),
      prefixIcon: Icon(icon, color: AppColors.primaryOrange, size: 20),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
      ),
    );
  }
}

class QuestionFormData {
  int order;
  String questionType;
  TextEditingController textCtrl;
  List<TextEditingController> optionsCtrls;
  TextEditingController? correctAnswerCtrl;
  TextEditingController? explanationCtrl;

  QuestionFormData({
    required this.order,
    required this.questionType,
    required this.textCtrl,
    required this.optionsCtrls,
    this.correctAnswerCtrl,
    this.explanationCtrl,
  });
}
