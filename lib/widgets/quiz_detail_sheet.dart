// lib/widgets/quiz_detail_sheet.dart
import 'package:flutter/material.dart';
import 'app_styles.dart';

class QuizDetailSheet extends StatelessWidget {
  final dynamic quiz;

  const QuizDetailSheet({Key? key, required this.quiz}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppStyles.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quiz.title, style: AppTextStyles.h2),
                  const SizedBox(height: AppStyles.spacingS),
                  Text(
                    quiz.courseName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingL),
                  Text('Descripción', style: AppTextStyles.h4),
                  const SizedBox(height: AppStyles.spacingS),
                  Text(quiz.description, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppStyles.spacingL),
                  _buildQuizInfo(quiz),
                  const SizedBox(height: AppStyles.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/quiz-attempt',
                          arguments: quiz,
                        );
                      },
                      style: AppStyles.primaryButton,
                      child: Text(quiz.isCompleted ? 'Reintentar' : 'Comenzar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfo(dynamic quiz) {
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: AppStyles.standardBorderRadius,
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.question_answer_outlined,
            'Preguntas',
            '${quiz.totalQuestions}',
          ),
          const Divider(height: AppStyles.spacingL),
          _buildInfoRow(
            Icons.check_circle_outline,
            'Puntaje mínimo',
            '${quiz.passingScore}%',
          ),
          if (quiz.lastScore != null) ...[
            const Divider(height: AppStyles.spacingL),
            _buildInfoRow(
              Icons.emoji_events_outlined,
              'Tu mejor puntaje',
              '${quiz.lastScore}%',
              color:
                  quiz.isPassed ? AppColors.successGreen : AppColors.errorRed,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.primaryOrange),
        const SizedBox(width: AppStyles.spacingS),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
