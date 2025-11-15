import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/course_detail_sheet.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _filter = 'all'; // all, enrolled, available

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Cursos'),
        actions: [
          if (context.watch<AppProvider>().isTeacher)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/create-course'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
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
                  return EmptyState(
                    icon: Icons.school_outlined,
                    title: 'No hay cursos',
                    message: _filter == 'enrolled'
                        ? 'Aún no te has inscrito en ningún curso'
                        : 'No hay cursos disponibles en este momento',
                    actionLabel:
                        _filter == 'enrolled' ? 'Explorar cursos' : null,
                    onAction: _filter == 'enrolled'
                        ? () => setState(() => _filter = 'available')
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadCourses(),
                  color: AppColors.primaryOrange,
                  child: ListView.builder(
                    padding: AppStyles.screenPadding,
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppStyles.spacingM),
                        child: CourseCard(
                          course: course,
                          onTap: () => _showCourseDetail(context, course),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingL,
        vertical: AppStyles.spacingM,
      ),
      child: Row(
        children: [
          _buildFilterChip('Todos', 'all'),
          const SizedBox(width: AppStyles.spacingS),
          _buildFilterChip('Inscritos', 'enrolled'),
          const SizedBox(width: AppStyles.spacingS),
          _buildFilterChip('Disponibles', 'available'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
      },
      backgroundColor: AppColors.backgroundWhite,
      selectedColor: AppColors.primaryOrange.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryOrange : AppColors.darkText,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.smallBorderRadius,
        side: BorderSide(
          color: isSelected
              ? AppColors.primaryOrange
              : AppColors.lightText.withOpacity(0.3),
        ),
      ),
    );
  }

  List<dynamic> _getFilteredCourses(AppProvider provider) {
    switch (_filter) {
      case 'enrolled':
        return provider.courses.where((c) => c.isEnrolled).toList();
      case 'available':
        return provider.courses.where((c) => !c.isEnrolled).toList();
      default:
        return provider.courses;
    }
  }

  void _showCourseDetail(BuildContext context, dynamic course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseDetailSheet(course: course),
    );
  }
}
