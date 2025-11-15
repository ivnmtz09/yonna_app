import 'package:flutter/material.dart';
import '../models/course_model.dart';
import 'app_styles.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseCard({
    Key? key,
    required this.course,
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
                      'Nivel ${course.level}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (course.isEnrolled)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.successGreen,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingM),
              Text(
                course.title,
                style: AppTextStyles.h4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppStyles.spacingS),
              Text(
                course.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightText,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppStyles.spacingM),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: AppColors.lightText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course.enrolledCount} inscritos',
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
