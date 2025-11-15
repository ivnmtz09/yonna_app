import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/yonna_drawer.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<AppProvider>();
    await provider.loadUserData();
    await Future.wait([
      provider.loadCourses(),
      provider.loadQuizzes(),
      provider.loadProgress(),
    ]);
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Yonna Akademia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navegar a notificaciones
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      drawer: YonnaDrawer(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryOrange,
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.user == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              );
            }

            final user = provider.user;
            if (user == null) {
              return const Center(
                child: Text('Error al cargar datos del usuario'),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyles.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo personalizado
                  _buildGreeting(user.firstName),
                  const SizedBox(height: AppStyles.spacingL),

                  // Barra de XP
                  XpProgressBar(
                    currentXp: user.xp,
                    xpForNextLevel: user.xpForNextLevel,
                    currentLevel: user.level,
                  ),
                  const SizedBox(height: AppStyles.spacingL),

                  // Estadísticas rápidas
                  _buildQuickStats(provider),
                  const SizedBox(height: AppStyles.spacingL),

                  // Accesos rápidos
                  _buildQuickActions(context, provider),
                  const SizedBox(height: AppStyles.spacingL),

                  // Progreso reciente
                  _buildRecentProgress(provider),
                  const SizedBox(height: AppStyles.spacingL),

                  // Cursos destacados
                  _buildFeaturedCourses(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreeting(String firstName) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = 'Buenos días';
      icon = Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      icon = Icons.wb_sunny;
    } else {
      greeting = 'Buenas noches';
      icon = Icons.nights_stay_outlined;
    }

    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: AppStyles.standardBorderRadius,
        boxShadow: AppStyles.standardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.whiteText, size: 32),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.whiteText.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  firstName,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.whiteText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.school_outlined,
            value:
                provider.courses.where((c) => c.isEnrolled).length.toString(),
            label: 'Cursos',
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz_outlined,
            value:
                provider.quizzes.where((q) => q.isCompleted).length.toString(),
            label: 'Quizzes',
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events_outlined,
            value: provider.user?.level.toString() ?? '1',
            label: 'Nivel',
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones rápidas', style: AppTextStyles.h4),
        const SizedBox(height: AppStyles.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.book_outlined,
                label: 'Explorar Cursos',
                color: AppColors.primaryOrange,
                onTap: () => Navigator.pushNamed(context, '/courses'),
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: _buildActionButton(
                icon: Icons.quiz,
                label: 'Hacer Quiz',
                color: AppColors.accentGreen,
                onTap: () => Navigator.pushNamed(context, '/quizzes'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.trending_up,
                label: 'Mi Progreso',
                color: AppColors.primaryBlue,
                onTap: () => Navigator.pushNamed(context, '/progress'),
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: _buildActionButton(
                icon: provider.isTeacher
                    ? Icons.add_circle_outline
                    : Icons.person_outline,
                label: provider.isTeacher ? 'Crear Curso' : 'Mi Perfil',
                color: provider.isTeacher
                    ? AppColors.successGreen
                    : AppColors.primaryOrange,
                onTap: () {
                  if (provider.isTeacher) {
                    Navigator.pushNamed(context, '/create-course');
                  } else {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: AppStyles.standardBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.standardBorderRadius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppStyles.standardBorderRadius,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: AppStyles.spacingS),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProgress(AppProvider provider) {
    if (provider.progress.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentProgress = provider.progress.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progreso reciente', style: AppTextStyles.h4),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/progress'),
              child: Text(
                'Ver todo',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        ...recentProgress.map((progress) => Padding(
              padding: const EdgeInsets.only(bottom: AppStyles.spacingM),
              child: Container(
                padding: AppStyles.cardPadding,
                decoration: AppStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.courseName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingS),
                    ClipRRect(
                      borderRadius: AppStyles.smallBorderRadius,
                      child: LinearProgressIndicator(
                        value: progress.completionPercentage / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.backgroundGray,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingS),
                    Text(
                      '${progress.completionPercentage.toStringAsFixed(0)}% completado',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildFeaturedCourses(AppProvider provider) {
    if (provider.courses.isEmpty) {
      return const SizedBox.shrink();
    }

    final availableCourses = provider.courses
        .where((c) => !c.isEnrolled && c.level <= provider.user!.level + 1)
        .take(3)
        .toList();

    if (availableCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cursos recomendados', style: AppTextStyles.h4),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/courses'),
              child: Text(
                'Ver todo',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        ...availableCourses.map((course) => Padding(
              padding: const EdgeInsets.only(bottom: AppStyles.spacingM),
              child: Container(
                padding: AppStyles.cardPadding,
                decoration: AppStyles.cardDecoration,
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        borderRadius: AppStyles.smallBorderRadius,
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AppColors.primaryOrange,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppStyles.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nivel ${course.level}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.lightText,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
