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
  bool _isLoading = false;

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
    super.dispose();
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

    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();

    try {
      await provider.apiService.createQuiz(
        courseId: _selectedCourseId!,
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
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
        const SnackBar(
          content: Text('Error al crear quiz'),
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
            const SizedBox(height: AppStyles.spacingXL),

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
}
