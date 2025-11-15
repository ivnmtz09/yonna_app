import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import 'app_styles.dart';

class QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;

  const QuizCard({
    Key? key,
    required this.quiz,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.standardBorderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.standardBorderRadius,
        child: Padding(
          padding: AppStyles.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    quiz.isCompleted ? Icons.check_circle : Icons.quiz_outlined,
                    color: quiz.isCompleted
                        ? AppColors.successGreen
                        : AppColors.primaryOrange,
                  ),
                  const SizedBox(width: AppStyles.spacingS),
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: AppTextStyles.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingS),
              Text(
                quiz.courseName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              Text(
                quiz.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppStyles.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${quiz.totalQuestions} preguntas',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (quiz.lastScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: quiz.isPassed
                            ? AppColors.successGreen.withOpacity(0.1)
                            : AppColors.errorRed.withOpacity(0.1),
                        borderRadius: AppStyles.smallBorderRadius,
                      ),
                      child: Text(
                        'Puntaje: ${quiz.lastScore}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: quiz.isPassed
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
