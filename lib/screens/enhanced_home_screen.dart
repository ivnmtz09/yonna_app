import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/yonna_drawer.dart';
import '../models/user_model.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  int? _totalUsers; // Cache para total de usuarios

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<AppProvider>();
    if (provider.user == null) {
      await provider.loadUserData();
    }
    
    final futures = [
      provider.loadCourses(),
      provider.loadQuizzes(),
      provider.loadProgress(),
      provider.loadNotifications(),
    ];
    
    // Si es admin, cargar también el total de usuarios
    if (provider.user?.isAdmin ?? false) {
      futures.add(_loadTotalUsers(provider));
    }
    
    await Future.wait(futures);
  }

  Future<void> _loadTotalUsers(AppProvider provider) async {
    try {
      final users = await provider.getAllUsers();
      if (mounted) {
        setState(() {
          _totalUsers = users.length;
        });
      }
    } catch (e) {
      print('❌ Error cargando total de usuarios: $e');
    }
  }

  Future<void> _refresh() async {
    final provider = context.read<AppProvider>();
    await _loadData();
    // Si es admin, recargar también usuarios
    if (provider.user?.isAdmin ?? false) {
      await _loadTotalUsers(provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Yonna Akademia'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (provider.unreadNotificationsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          provider.unreadNotificationsCount > 9
                              ? '9+'
                              : provider.unreadNotificationsCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: const YonnaDrawer(),
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
              return _buildErrorState('Error al cargar datos del usuario');
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyles.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo personalizado con rol
                  _buildGreetingSection(user),
                  const SizedBox(height: AppStyles.spacingL),

                  // Contenido específico por rol
                  if (user.isUser) _buildUserHome(provider),
                  if (user.isModerator) _buildModeratorHome(provider),
                  if (user.isAdmin) _buildAdminHome(provider, _totalUsers),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreetingSection(UserModel user) {
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
        boxShadow: AppStyles.largeShadow,
      ),
      child: Column(
        children: [
          Row(
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
                    Text(
                      user.firstName,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.whiteText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.2),
                        borderRadius: AppStyles.smallBorderRadius,
                      ),
                      child: Text(
                        user.roleDisplayName.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.whiteText,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          if (user.isUser)
            XpProgressBar(
              currentXp: user.xp,
              xpForNextLevel: user.xpForNextLevel,
              currentLevel: user.level,
            ),
        ],
      ),
    );
  }

  Widget _buildUserHome(AppProvider provider) {
    return Column(
      children: [
        // Estadísticas rápidas
        _buildUserStats(provider),
        const SizedBox(height: AppStyles.spacingL),

        // Accesos rápidos
        _buildQuickActions(context, provider),
        const SizedBox(height: AppStyles.spacingL),

        // Progreso reciente
        _buildRecentProgress(provider),
        const SizedBox(height: AppStyles.spacingL),

        // Cursos recomendados
        _buildFeaturedCourses(provider),
      ],
    );
  }

  Widget _buildModeratorHome(AppProvider provider) {
    final totalCourses = provider.courses.length;
    final totalQuizzes = provider.quizzes.length;
    final enrolledUsers = provider.courses
        .fold(0, (sum, course) => sum + course.enrolledStudentsCount);

    return Column(
      children: [
        // Estadísticas de moderador
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.school_outlined,
                value: totalCourses.toString(),
                label: 'Cursos Creados',
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: _buildStatCard(
                icon: Icons.quiz_outlined,
                value: totalQuizzes.toString(),
                label: 'Quizzes Creados',
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outlined,
                value: enrolledUsers.toString(),
                label: 'Usuarios Inscritos',
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingL),

        // Acciones de moderador
        _buildModeratorActions(context),
        const SizedBox(height: AppStyles.spacingL),

        // Cursos recientes
        _buildRecentCourses(provider),
      ],
    );
  }

  Widget _buildAdminHome(AppProvider provider, int? totalUsers) {
    return Column(
      children: [
        // Estadísticas de administrador
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outlined,
                value: totalUsers?.toString() ?? '...',
                label: 'Total Usuarios',
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: _buildStatCard(
                icon: Icons.school_outlined,
                value: provider.courses.length.toString(),
                label: 'Total Cursos',
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.quiz_outlined,
                value: provider.quizzes.length.toString(),
                label: 'Total Quizzes',
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                value: '0', // TODO: Obtener de estadísticas
                label: 'Actividad Hoy',
                color: AppColors.warningYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingL),

        // Acciones de administrador
        _buildAdminActions(context),
        const SizedBox(height: AppStyles.spacingL),

        // Resumen de actividad
        _buildAdminOverview(provider, totalUsers),
      ],
    );
  }

  Widget _buildUserStats(AppProvider provider) {
    final enrolledCourses = provider.courses.where((c) => c.isEnrolled).length;
    final completedQuizzes =
        provider.quizzes.where((q) => q.isCompleted).length;
    final inProgressCourses = provider.progress
        .where(
            (p) => p.percentage > 0 && p.percentage < 100)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.school_outlined,
            value: enrolledCourses.toString(),
            label: 'Cursos Inscritos',
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz_outlined,
            value: completedQuizzes.toString(),
            label: 'Quizzes Completados',
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            value: inProgressCourses.toString(),
            label: 'En Progreso',
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
        Wrap(
          spacing: AppStyles.spacingM,
          runSpacing: AppStyles.spacingM,
          children: [
            _buildActionButton(
              icon: Icons.book_outlined,
              label: 'Explorar Cursos',
              color: AppColors.primaryOrange,
              onTap: () => Navigator.pushNamed(context, '/courses'),
            ),
            _buildActionButton(
              icon: Icons.quiz,
              label: 'Hacer Quiz',
              color: AppColors.accentGreen,
              onTap: () => Navigator.pushNamed(context, '/quizzes'),
            ),
            _buildActionButton(
              icon: Icons.trending_up,
              label: 'Mi Progreso',
              color: AppColors.primaryBlue,
              onTap: () => Navigator.pushNamed(context, '/progress'),
            ),
            _buildActionButton(
              icon: Icons.emoji_events_outlined,
              label: 'Clasificación',
              color: AppColors.warningYellow,
              onTap: () => Navigator.pushNamed(context, '/leaderboard'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeratorActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestión de Contenido', style: AppTextStyles.h4),
        const SizedBox(height: AppStyles.spacingM),
        Wrap(
          spacing: AppStyles.spacingM,
          runSpacing: AppStyles.spacingM,
          children: [
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Crear Curso',
              color: AppColors.successGreen,
              onTap: () => Navigator.pushNamed(context, '/create-course'),
            ),
            _buildActionButton(
              icon: Icons.add_box_outlined,
              label: 'Crear Quiz',
              color: AppColors.accentGreen,
              onTap: () => Navigator.pushNamed(context, '/create-quiz'),
            ),
            _buildActionButton(
              icon: Icons.analytics_outlined,
              label: 'Ver Estadísticas',
              color: AppColors.primaryBlue,
              onTap: () => Navigator.pushNamed(context, '/admin-stats'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Panel de Administración', style: AppTextStyles.h4),
        const SizedBox(height: AppStyles.spacingM),
        Wrap(
          spacing: AppStyles.spacingM,
          runSpacing: AppStyles.spacingM,
          children: [
            _buildActionButton(
              icon: Icons.people_outlined,
              label: 'Gestionar Usuarios',
              color: AppColors.primaryBlue,
              onTap: () => Navigator.pushNamed(context, '/manage-users'),
            ),
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Crear Curso',
              color: AppColors.successGreen,
              onTap: () => Navigator.pushNamed(context, '/create-course'),
            ),
            _buildActionButton(
              icon: Icons.bar_chart,
              label: 'Estadísticas',
              color: AppColors.primaryOrange,
              onTap: () => Navigator.pushNamed(context, '/admin-stats'),
            ),
            _buildActionButton(
              icon: Icons.settings,
              label: 'Configuración',
              color: AppColors.lightText,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración próximamente')),
                );
              },
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
    return SizedBox(
      width: 110,
      child: Material(
        color: Colors.white,
        borderRadius: AppStyles.standardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppStyles.standardBorderRadius,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: AppStyles.standardBorderRadius,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildRecentProgress(AppProvider provider) {
    if (provider.progress.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up,
        title: 'Aún no tienes progreso',
        subtitle: 'Inscríbete en un curso para comenzar tu aprendizaje',
      );
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            progress.courseTitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${progress.percentage.toStringAsFixed(0)}%',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.spacingS),
                    ClipRRect(
                      borderRadius: AppStyles.smallBorderRadius,
                      child: LinearProgressIndicator(
                        value: progress.percentage / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.backgroundGray,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildFeaturedCourses(AppProvider provider) {
    final availableCourses = provider.courses
        .where((c) =>
            !c.isEnrolled && c.levelRequired <= (provider.user?.level ?? 1) + 1)
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryOrange.withOpacity(0.1),
                                  borderRadius: AppStyles.smallBorderRadius,
                                ),
                                child: Text(
                                  'Nivel ${course.levelRequired}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  borderRadius: AppStyles.smallBorderRadius,
                                ),
                                child: Text(
                                  '${course.enrolledStudentsCount} estudiantes',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
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

  Widget _buildRecentCourses(AppProvider provider) {
    final recentCourses = provider.courses.take(3).toList();

    if (recentCourses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.school_outlined,
        title: 'No hay cursos',
        subtitle: 'Crea tu primer curso para comenzar',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cursos recientes', style: AppTextStyles.h4),
        const SizedBox(height: AppStyles.spacingM),
        ...recentCourses.map((course) => Padding(
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
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: AppStyles.smallBorderRadius,
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AppColors.successGreen,
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
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.successGreen.withOpacity(0.1),
                                  borderRadius: AppStyles.smallBorderRadius,
                                ),
                                child: Text(
                                  'Nivel ${course.levelRequired}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  borderRadius: AppStyles.smallBorderRadius,
                                ),
                                child: Text(
                                  '${course.enrolledStudentsCount} estudiantes',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
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

  Widget _buildAdminOverview(AppProvider provider, int? totalUsers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen del Sistema', style: AppTextStyles.h4),
        const SizedBox(height: AppStyles.spacingM),
        Container(
          padding: AppStyles.cardPadding,
          decoration: AppStyles.cardDecoration,
          child: Column(
            children: [
              _buildOverviewItem(
                  'Cursos activos', provider.courses.length.toString()),
              const Divider(),
              _buildOverviewItem(
                  'Quizzes activos', provider.quizzes.length.toString()),
              const Divider(),
              _buildOverviewItem('Usuarios registrados', totalUsers?.toString() ?? '0'),
              const Divider(),
              _buildOverviewItem('Actividad hoy', '0'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            )),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.lightText),
          const SizedBox(height: AppStyles.spacingM),
          Text(
            title,
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: AppStyles.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.errorRed),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              message,
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.spacingL),
            ElevatedButton(
              onPressed: _refresh,
              style: AppStyles.primaryButton,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
