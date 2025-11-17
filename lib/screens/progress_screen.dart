import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/progress_card.dart';
import '../widgets/empty_state.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Mi Progreso'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.progress.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            );
          }

          if (provider.progress.isEmpty) {
            return EmptyState(
              icon: Icons.trending_up,
              title: 'Sin progreso aún',
              message: 'Inscríbete en un curso para comenzar tu aprendizaje',
              actionLabel: 'Explorar cursos',
              onAction: () => Navigator.pushNamed(context, '/courses'),
            );
          }

          final totalCourses = provider.progress.length;
          final completedCourses =
              provider.progress.where((p) => p.courseCompleted).length;
          final totalXp =
              provider.progress.fold(0, (sum, p) => sum + p.xpEarned);
          final avgCompletion = totalCourses > 0
              ? provider.progress.fold(
                  0.0,
                  (sum, p) => sum + p.percentage,
                ) /
                totalCourses
              : 0.0;

          return RefreshIndicator(
            onRefresh: () => provider.loadProgress(),
            color: AppColors.primaryOrange,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyles.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen general
                  _buildOverallSummary(
                    totalCourses: totalCourses,
                    completedCourses: completedCourses,
                    totalXp: totalXp,
                    avgCompletion: avgCompletion,
                  ),
                  const SizedBox(height: AppStyles.spacingL),

                  // Lista de progreso por curso
                  Text('Progreso por curso', style: AppTextStyles.h4),
                  const SizedBox(height: AppStyles.spacingM),

                  ...provider.progress.map(
                    (progress) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppStyles.spacingM),
                      child: ProgressCard(
                        progress: progress,
                        onTap: () => _showProgressDetail(context, progress),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallSummary({
    required int totalCourses,
    required int completedCourses,
    required int totalXp,
    required double avgCompletion,
  }) {
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppStyles.standardBorderRadius,
        boxShadow: AppStyles.largeShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.whiteText,
                size: 32,
              ),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen General',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.whiteText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu progreso de aprendizaje',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.whiteText.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingL),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.school_outlined,
                  value: '$completedCourses/$totalCourses',
                  label: 'Cursos completados',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.whiteText.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.star_border,
                  value: '$totalXp',
                  label: 'XP ganado',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          Text(
            'Progreso promedio',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.whiteText.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          ClipRRect(
            borderRadius: AppStyles.smallBorderRadius,
            child: LinearProgressIndicator(
              value: avgCompletion / 100,
              minHeight: 12,
              backgroundColor: AppColors.whiteText.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.whiteText,
              ),
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            '${avgCompletion.toStringAsFixed(1)}%',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.whiteText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.whiteText, size: 24),
        const SizedBox(height: AppStyles.spacingS),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.whiteText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.whiteText.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showProgressDetail(BuildContext context, dynamic progress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProgressDetailSheet(progress: progress),
    );
  }
}

class ProgressDetailSheet extends StatelessWidget {
  final dynamic progress;

  const ProgressDetailSheet({Key? key, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
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
                  Text(progress.courseTitle, style: AppTextStyles.h2),
                  const SizedBox(height: AppStyles.spacingL),

                  // Progreso visual
                  Container(
                    padding: AppStyles.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: AppStyles.standardBorderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progreso del curso',
                                style: AppTextStyles.bodyMedium),
                            Text(
                              '${progress.percentage.toStringAsFixed(0)}%',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppStyles.spacingM),
                        ClipRRect(
                          borderRadius: AppStyles.smallBorderRadius,
                          child: LinearProgressIndicator(
                            value: progress.percentage / 100,
                            minHeight: 16,
                            backgroundColor: AppColors.backgroundWhite,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingL),

                  // Estadísticas detalladas
                  Text('Estadísticas', style: AppTextStyles.h4),
                  const SizedBox(height: AppStyles.spacingM),

                  _buildStatRow(
                    icon: Icons.quiz_outlined,
                    label: 'Quizzes completados',
                    value:
                        '${progress.completedQuizzes}/${progress.totalQuizzes}',
                  ),
                  const Divider(height: AppStyles.spacingL),

                  _buildStatRow(
                    icon: Icons.star_border,
                    label: 'XP obtenido',
                    value: '${progress.xpEarned} XP',
                  ),
                  const Divider(height: AppStyles.spacingL),

                  _buildStatRow(
                    icon: Icons.calendar_today,
                    label: 'Última actualización',
                    value: _formatDate(progress.updatedAt),
                  ),

                  if (progress.completedAt != null) ...[
                    const Divider(height: AppStyles.spacingL),
                    _buildStatRow(
                      icon: Icons.check_circle,
                      label: 'Completado el',
                      value: _formatDate(progress.completedAt!),
                    ),
                  ],

                  const SizedBox(height: AppStyles.spacingL),

                  if (progress.courseCompleted)
                    Container(
                      width: double.infinity,
                      padding: AppStyles.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: AppStyles.standardBorderRadius,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.celebration,
                            color: AppColors.successGreen,
                            size: 32,
                          ),
                          const SizedBox(width: AppStyles.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Curso completado!',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.successGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Has terminado todos los quizzes',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryOrange, size: 24),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? 'año' : 'años'}';
    }
  }
}
