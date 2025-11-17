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
              // Header con dificultad y estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: quiz.difficultyColor.withOpacity(0.1),
                      borderRadius: AppStyles.smallBorderRadius,
                    ),
                    child: Text(
                      quiz.difficultyDisplayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: quiz.difficultyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (quiz.isPassed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: AppStyles.smallBorderRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: AppColors.successGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Aprobado',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (quiz.isCompleted && !quiz.isPassed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningYellow.withOpacity(0.1),
                        borderRadius: AppStyles.smallBorderRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: AppColors.warningYellow,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reintentar',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warningYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingM),

              // Título del quiz
              Text(
                quiz.title,
                style: AppTextStyles.h4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppStyles.spacingS),

              // Descripción
              if (quiz.description.isNotEmpty) ...[
                Text(
                  quiz.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.lightText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppStyles.spacingM),
              ],

              // Información del quiz
              Wrap(
                spacing: AppStyles.spacingM,
                runSpacing: 8,
                children: [
                  // Número de preguntas
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.quiz_outlined,
                        size: 16,
                        color: AppColors.lightText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.questionCount} preguntas',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),

                  // Límite de tiempo
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.lightText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        quiz.formattedTimeLimit,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),

                  // XP recompensa
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_border,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.xpReward} XP',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Puntuación mínima
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 16,
                        color: AppColors.lightText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Aprueba: ${quiz.passingScore.toStringAsFixed(0)}%',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),

              // Score del usuario (si tiene intentos)
              if (quiz.isCompleted) ...[
                const SizedBox(height: AppStyles.spacingM),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: quiz.isPassed
                        ? AppColors.successGreen.withOpacity(0.1)
                        : AppColors.warningYellow.withOpacity(0.1),
                    borderRadius: AppStyles.smallBorderRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        quiz.isPassed ? Icons.emoji_events : Icons.trending_up,
                        color: quiz.isPassed
                            ? AppColors.successGreen
                            : AppColors.warningYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.isPassed ? 'Aprobado' : 'Mejor intento',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: quiz.isPassed
                                    ? AppColors.successGreen
                                    : AppColors.warningYellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Puntuación: ${quiz.bestScore.toStringAsFixed(1)}%',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Intentos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Intentos',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.lightText,
                            ),
                          ),
                          Text(
                            '${quiz.userAttempts}/${quiz.maxAttempts}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Mensaje si no puede intentar
              if (!quiz.canAttempt) ...[
                const SizedBox(height: AppStyles.spacingM),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: AppStyles.smallBorderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.block,
                        color: AppColors.errorRed,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sin intentos disponibles',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
