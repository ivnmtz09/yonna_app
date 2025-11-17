import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();
    final success = await provider.createCourse(
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Curso creado exitosamente'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al crear curso'),
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
        title: const Text('Crear Curso'),
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
                    Icons.school_outlined,
                    color: AppColors.accentGreen,
                    size: 32,
                  ),
                  const SizedBox(width: AppStyles.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo Curso',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Comparte tu conocimiento del Wayuunaiki',
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
            Text('Información del curso', style: AppTextStyles.h4),
            const SizedBox(height: AppStyles.spacingM),
            TextFormField(
              controller: _titleCtrl,
              decoration: AppStyles.inputDecoration(
                labelText: 'Título del curso',
                icon: Icons.title,
                hintText: 'Ej: Wayuunaiki Básico',
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
                hintText: 'Describe el contenido del curso',
              ),
              maxLines: 5,
              maxLength: 500,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingrese una descripción' : null,
            ),
            const SizedBox(height: AppStyles.spacingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCourse,
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
                    : const Text('Crear Curso'),
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
