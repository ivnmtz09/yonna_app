import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_icons.dart';
import '../models/quiz_model.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/common/glass_icon_badge.dart';
import 'quiz/glass_quiz_lesson_screen.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior minimalista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(21),
                      child: GlassContainer(
                        width: 42,
                        height: 42,
                        borderRadius: BorderRadius.circular(21),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Evaluaciones & Quizzes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    if (context.watch<AppProvider>().canManage)
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/create-quiz'),
                        borderRadius: BorderRadius.circular(21),
                        child: GlassContainer(
                          width: 42,
                          height: 42,
                          borderRadius: BorderRadius.circular(21),
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            Icons.add_rounded,
                            size: 22,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Filtros horizontales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildFilterChip('Todos', 'all', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Completados', 'completed', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pendientes', 'pending', isDark),
                  ],
                ),
              ),

              // Lista de Quizzes
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.quizzes.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOrange,
                        ),
                      );
                    }

                    final filteredQuizzes = _getFilteredQuizzes(provider);

                    if (filteredQuizzes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GlassIconBadge(
                              icon: Icons.quiz_outlined,
                              color: isDark ? Colors.white38 : AppColors.lightText,
                              size: 64,
                              iconSize: 32,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No hay quizzes disponibles',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.loadQuizzes(),
                      color: AppColors.primaryOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredQuizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = filteredQuizzes[index];
                          return _buildQuizCard(quiz, isDark);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() => _filter = value);
      },
      selectedColor: AppColors.primaryOrange.withValues(alpha: 0.25),
      checkmarkColor: AppColors.primaryOrange,
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primaryOrange : (isDark ? Colors.white70 : AppColors.darkText),
      ),
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryOrange : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GlassQuizLessonScreen(quiz: quiz),
            ),
          );
        },
        child: Row(
          children: [
            const GlassIconBadge(
              icon: AppIcons.quiz,
              color: AppColors.primaryOrange,
              size: 46,
              iconSize: 24,
              borderRadius: 23,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppIcons.xpColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(AppIcons.xp, size: 12, color: AppIcons.xpColor),
                            const SizedBox(width: 3),
                            Text(
                              '+${quiz.xpReward} XP',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppIcons.xpColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quiz.questions.length} preguntas',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white54 : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.primaryOrange,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  List<QuizModel> _getFilteredQuizzes(AppProvider provider) {
    switch (_filter) {
      case 'completed':
        return provider.quizzes.where((q) => provider.completedQuizzes.contains(q.id)).toList();
      case 'pending':
        return provider.quizzes.where((q) => !provider.completedQuizzes.contains(q.id)).toList();
      default:
        return provider.quizzes;
    }
  }
}
