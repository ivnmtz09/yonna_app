import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_styles.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _apiService.getAdminStatistics();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar estadísticas: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppColors.primaryOrange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppStyles.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con resumen
                    Container(
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
                              const Icon(
                                Icons.dashboard,
                                color: AppColors.whiteText,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Panel de Control',
                                      style: AppTextStyles.h3.copyWith(
                                        color: AppColors.whiteText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Visión general de la plataforma',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.whiteText
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingL),

                    // Estadísticas de usuarios
                    Text('Usuarios', style: AppTextStyles.h4),
                    const SizedBox(height: AppStyles.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.people,
                            value: '${_stats?['total_users'] ?? 0}',
                            label: 'Total',
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.person_add,
                            value: '${_stats?['new_users_this_month'] ?? 0}',
                            label: 'Este mes',
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.admin_panel_settings,
                            value: '${_stats?['admins_count'] ?? 0}',
                            label: 'Admins',
                            color: AppColors.errorRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.shield,
                            value: '${_stats?['moderators_count'] ?? 0}',
                            label: 'Moderadores',
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.spacingL),

                    // Estadísticas de contenido
                    Text('Contenido', style: AppTextStyles.h4),
                    const SizedBox(height: AppStyles.spacingM),
                    _buildContentStats(),
                    const SizedBox(height: AppStyles.spacingL),

                    // Actividad
                    Text('Actividad', style: AppTextStyles.h4),
                    const SizedBox(height: AppStyles.spacingM),
                    _buildActivityStats(),
                    const SizedBox(height: AppStyles.spacingL),

                    // Top usuarios
                    Text('Top Usuarios', style: AppTextStyles.h4),
                    const SizedBox(height: AppStyles.spacingM),
                    _buildTopUsers(),
                  ],
                ),
              ),
            ),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: color),
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

  Widget _buildContentStats() {
    return Container(
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          _buildStatRow(
            Icons.school_outlined,
            'Cursos totales',
            '${_stats?['total_courses'] ?? 0}',
            AppColors.primaryOrange,
          ),
          const Divider(height: 24),
          _buildStatRow(
            Icons.quiz_outlined,
            'Quizzes totales',
            '${_stats?['total_quizzes'] ?? 0}',
            AppColors.accentGreen,
          ),
          const Divider(height: 24),
          _buildStatRow(
            Icons.article_outlined,
            'Inscripciones',
            '${_stats?['total_enrollments'] ?? 0}',
            AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats() {
    return Container(
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          _buildStatRow(
            Icons.task_alt,
            'Quizzes completados',
            '${_stats?['quizzes_completed'] ?? 0}',
            AppColors.successGreen,
          ),
          const Divider(height: 24),
          _buildStatRow(
            Icons.trending_up,
            'XP total ganado',
            '${_stats?['total_xp_earned'] ?? 0}',
            AppColors.warningYellow,
          ),
          const Divider(height: 24),
          _buildStatRow(
            Icons.access_time,
            'Intentos de quiz',
            '${_stats?['total_quiz_attempts'] ?? 0}',
            AppColors.infoBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsers() {
    final topUsers = _stats?['top_users'] as List<dynamic>? ?? [];

    if (topUsers.isEmpty) {
      return Container(
        padding: AppStyles.cardPadding,
        decoration: AppStyles.cardDecoration,
        child: Center(
          child: Text(
            'No hay datos de usuarios aún',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightText,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: List.generate(
          topUsers.length > 5 ? 5 : topUsers.length,
          (index) {
            final user = topUsers[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < topUsers.length - 1 ? 16 : 0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getPositionColor(index).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _getPositionColor(index),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? 'Usuario',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Nivel ${user['level'] ?? 1}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      '${user['xp'] ?? 0} XP',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 0:
        return AppColors.warningYellow; // Oro
      case 1:
        return AppColors.lightText; // Plata
      case 2:
        return AppColors.primaryOrange; // Bronce
      default:
        return AppColors.primaryBlue;
    }
  }
}
