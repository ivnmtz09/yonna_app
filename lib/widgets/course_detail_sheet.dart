// lib/widgets/course_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'app_styles.dart';

class CourseDetailSheet extends StatelessWidget {
  final dynamic course;

  const CourseDetailSheet({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
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
                  Text(course.title, style: AppTextStyles.h2),
                  const SizedBox(height: AppStyles.spacingS),
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
                      const SizedBox(width: AppStyles.spacingS),
                      const Icon(
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
                  const SizedBox(height: AppStyles.spacingL),
                  Text('Descripción', style: AppTextStyles.h4),
                  const SizedBox(height: AppStyles.spacingS),
                  Text(
                    course.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppStyles.spacingL),
                  if (course.isEnrolled) ...[
                    Container(
                      padding: AppStyles.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: AppStyles.standardBorderRadius,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.successGreen,
                          ),
                          const SizedBox(width: AppStyles.spacingS),
                          Text(
                            'Ya estás inscrito en este curso',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success =
                              await provider.enrollInCourse(course.id);
                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Te has inscrito exitosamente!'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    provider.error ?? 'Error al inscribirse'),
                                backgroundColor: AppColors.errorRed,
                              ),
                            );
                          }
                        },
                        style: AppStyles.primaryButton,
                        child: const Text('Inscribirse'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
