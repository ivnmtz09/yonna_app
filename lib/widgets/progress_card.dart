import 'package:flutter/material.dart';
import '../models/progress_model.dart';
import 'app_styles.dart';

class ProgressCard extends StatelessWidget {
  final ProgressModel progress;
  final VoidCallback onTap;

  const ProgressCard({
    Key? key,
    required this.progress,
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
                  Expanded(
                    child: Text(
                      progress.courseTitle,
                      style: AppTextStyles.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (progress.courseCompleted)
                    const Icon(
                      Icons.celebration,
                      color: AppColors.successGreen,
                    ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${progress.percentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingS),
              ClipRRect(
                borderRadius: AppStyles.smallBorderRadius,
                child: LinearProgressIndicator(
                  value: progress.percentage / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.backgroundGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 16,
                        color: AppColors.lightText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.xpEarned} XP',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    '${progress.completedQuizzes}/${progress.totalQuizzes} quizzes',
                    style: AppTextStyles.bodySmall,
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
