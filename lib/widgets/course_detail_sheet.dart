import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_icons.dart';
import '../providers/app_provider.dart';
import 'app_styles.dart';
import 'glass/glass_button.dart';
import 'glass/glass_card.dart';
import 'glass/glass_sheet.dart';
import 'common/glass_icon_badge.dart';

class CourseDetailSheet extends StatelessWidget {
  final dynamic course;

  const CourseDetailSheet({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnrolled = course.isEnrolled ?? provider.isEnrolled(course.id);

    return GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassIconBadge(
                icon: AppIcons.lesson,
                color: AppColors.primaryOrange,
                size: 52,
                iconSize: 26,
                borderRadius: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Nivel ${course.levelRequired ?? course.level ?? 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'DESCRIPCIÓN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white60 : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            course.description ?? 'Sin descripción disponible',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: isDark ? Colors.white70 : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),

          if (isEnrolled) ...[
            GlassCard(
              borderRadius: BorderRadius.circular(16),
              backgroundColor: AppIcons.successColor.withValues(alpha: isDark ? 0.15 : 0.10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppIcons.successColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Ya estás inscrito en este curso',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            GlassButton(
              text: 'INSCRIBIRSE AL CURSO',
              icon: Icons.school_rounded,
              isPrimary: true,
              height: 48,
              width: double.infinity,
              onPressed: () async {
                final success = await provider.enrollInCourse(course.id);
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
                      content: Text(provider.error ?? 'Error al inscribirse'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              },
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
