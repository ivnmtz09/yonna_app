import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/quiz_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/quiz_detail_sheet.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  String _filter = 'all'; // all, completed, pending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Quizzes'),
        actions: [
          if (context.watch<AppProvider>().isModerator)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/create-quiz'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
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
                  return EmptyState(
                    icon: Icons.quiz_outlined,
                    title: 'No hay quizzes',
                    message: _filter == 'completed'
                        ? 'Aún no has completado ningún quiz'
                        : 'No hay quizzes disponibles en este momento',
                    actionLabel: _filter == 'completed' ? 'Ver todos' : null,
                    onAction: _filter == 'completed'
                        ? () => setState(() => _filter = 'all')
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadQuizzes(),
                  color: AppColors.primaryOrange,
                  child: ListView.builder(
                    padding: AppStyles.screenPadding,
                    itemCount: filteredQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = filteredQuizzes[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppStyles.spacingM),
                        child: QuizCard(
                          quiz: quiz,
                          onTap: () => _showQuizDetail(context, quiz),
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
          _buildFilterChip('Completados', 'completed'),
          const SizedBox(width: AppStyles.spacingS),
          _buildFilterChip('Pendientes', 'pending'),
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

  List<dynamic> _getFilteredQuizzes(AppProvider provider) {
    switch (_filter) {
      case 'completed':
        return provider.quizzes.where((q) => q.isCompleted).toList();
      case 'pending':
        return provider.quizzes.where((q) => !q.isCompleted).toList();
      default:
        return provider.quizzes;
    }
  }

  void _showQuizDetail(BuildContext context, dynamic quiz) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuizDetailSheet(quiz: quiz),
    );
  }
}
