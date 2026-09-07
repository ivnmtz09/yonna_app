import 'package:flutter/material.dart';
import '../core/constants/app_icons.dart';
import '../models/quiz_model.dart';
import '../screens/quiz/glass_quiz_lesson_screen.dart';
import 'app_styles.dart';
import 'glass/glass_button.dart';
import 'glass/glass_sheet.dart';
import 'common/glass_icon_badge.dart';

class QuizDetailSheet extends StatelessWidget {
  final QuizModel quiz;

  const QuizDetailSheet({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlassIconBadge(
                icon: AppIcons.quiz,
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
                      quiz.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz.courseTitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (quiz.description.isNotEmpty) ...[
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
              quiz.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark ? Colors.white70 : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              _buildMetricChip(
                icon: AppIcons.xp,
                label: '+${quiz.xpReward} XP',
                color: AppIcons.xpColor,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildMetricChip(
                icon: Icons.timer_outlined,
                label: quiz.formattedTimeLimit,
                color: AppColors.primaryBlue,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildMetricChip(
                icon: Icons.help_outline_rounded,
                label: '${quiz.questions.length} preguntas',
                color: AppIcons.successColor,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          GlassButton(
            text: quiz.isCompleted ? 'REINTENTAR EVALUACIÓN' : 'COMENZAR EVALUACIÓN',
            icon: Icons.play_arrow_rounded,
            isPrimary: true,
            height: 48,
            width: double.infinity,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GlassQuizLessonScreen(quiz: quiz),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
