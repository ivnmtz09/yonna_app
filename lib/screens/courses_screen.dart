import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_icons.dart';
import '../models/course_model.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/common/glass_icon_badge.dart';
import '../widgets/course_detail_sheet.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
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
                      'Cursos de Wayuunaiki',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    if (context.watch<AppProvider>().canManage)
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/create-course'),
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
                    _buildFilterChip('Inscritos', 'enrolled', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Disponibles', 'available', isDark),
                  ],
                ),
              ),

              // Lista de Cursos
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.courses.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOrange,
                        ),
                      );
                    }

                    final filteredCourses = _getFilteredCourses(provider);

                    if (filteredCourses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GlassIconBadge(
                              icon: Icons.school_outlined,
                              color: isDark ? Colors.white38 : AppColors.lightText,
                              size: 64,
                              iconSize: 32,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No hay cursos en esta sección',
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
                      onRefresh: () => provider.loadCourses(),
                      color: AppColors.primaryOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                          return _buildCourseCard(course, isDark);
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

  Widget _buildCourseCard(CourseModel course, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CourseDetailSheet(course: course),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GlassIconBadge(
                  icon: AppIcons.lesson,
                  color: AppColors.primaryOrange,
                  size: 44,
                  iconSize: 22,
                  borderRadius: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Nivel ${course.levelRequired}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${course.estimatedDuration} horas',
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
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white30 : Colors.black26,
                  size: 24,
                ),
              ],
            ),
            if (course.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? Colors.white70 : AppColors.lightText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<CourseModel> _getFilteredCourses(AppProvider provider) {
    switch (_filter) {
      case 'enrolled':
        return provider.enrolledCourses;
      case 'available':
        return provider.courses.where((c) => !provider.isEnrolled(c.id)).toList();
      default:
        return provider.courses;
    }
  }
}
