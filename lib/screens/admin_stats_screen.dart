import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../core/constants/app_icons.dart';
import '../services/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/common/glass_icon_badge.dart';

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
                      'Panel de Administración',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/manage-users'),
                      borderRadius: BorderRadius.circular(21),
                      child: GlassContainer(
                        width: 42,
                        height: 42,
                        borderRadius: BorderRadius.circular(21),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.people_alt_outlined,
                          size: 20,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOrange,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStats,
                        color: AppColors.primaryOrange,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Grid de Métricas Principales (KPIs)
                              _buildKpiGrid(isDark),
                              const SizedBox(height: 16),

                              // 2. Gráfico Syncfusion: Distribución del Sistema
                              _buildChartCard(isDark),
                              const SizedBox(height: 16),

                              // 3. Accesos rápidos de gestión
                              Text(
                                'GESTIÓN RÁPIDA',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white60 : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 10),

                              _buildAdminNavTile(
                                icon: Icons.manage_accounts_outlined,
                                title: 'Gestión de Usuarios y Roles',
                                subtitle: 'Administrar permisos, niveles y estados',
                                isDark: isDark,
                                onTap: () => Navigator.pushNamed(context, '/manage-users'),
                              ),
                              const SizedBox(height: 8),

                              _buildAdminNavTile(
                                icon: Icons.add_circle_outline_rounded,
                                title: 'Crear Nuevo Curso',
                                subtitle: 'Añadir cursos de Wayuunaiki por niveles',
                                isDark: isDark,
                                onTap: () => Navigator.pushNamed(context, '/create-course'),
                              ),
                              const SizedBox(height: 8),

                              _buildAdminNavTile(
                                icon: Icons.quiz_outlined,
                                title: 'Crear Nuevo Quiz',
                                subtitle: 'Crear evaluaciones interactivas con XP',
                                isDark: isDark,
                                onTap: () => Navigator.pushNamed(context, '/create-quiz'),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(bool isDark) {
    final users = _stats?['total_users'] ?? _stats?['users_count'] ?? 8;
    final courses = _stats?['total_courses'] ?? _stats?['courses_count'] ?? 5;
    final quizzes = _stats?['total_quizzes'] ?? _stats?['quizzes_count'] ?? 5;
    final attempts = _stats?['total_attempts'] ?? 14;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildKpiCard(
                title: 'Usuarios',
                value: '$users',
                icon: Icons.people_outline_rounded,
                color: AppColors.primaryBlue,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildKpiCard(
                title: 'Cursos',
                value: '$courses',
                icon: Icons.auto_stories_outlined,
                color: AppColors.primaryOrange,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _buildKpiCard(
                title: 'Quizzes',
                value: '$quizzes',
                icon: Icons.quiz_outlined,
                color: AppIcons.successColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildKpiCard(
                title: 'Preguntas',
                value: '$attempts',
                icon: Icons.task_alt_rounded,
                color: AppIcons.vocabColor,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          GlassIconBadge(
            icon: icon,
            color: color,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.darkText,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : AppColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(bool isDark) {
    final chartData = [
      _PieData('Principiante', 40, AppColors.primaryOrange),
      _PieData('Intermedio', 35, AppColors.primaryBlue),
      _PieData('Avanzado', 25, AppIcons.successColor),
    ];

    return GlassCard(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución Curricular por Nivel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: SfCircularChart(
              margin: EdgeInsets.zero,
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : AppColors.darkText,
                ),
              ),
              series: <CircularSeries<_PieData, String>>[
                DoughnutSeries<_PieData, String>(
                  dataSource: chartData,
                  xValueMapper: (_PieData data, _) => data.category,
                  yValueMapper: (_PieData data, _) => data.value,
                  pointColorMapper: (_PieData data, _) => data.color,
                  innerRadius: '65%',
                  radius: '90%',
                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          GlassIconBadge(
            icon: icon,
            color: AppColors.primaryOrange,
            size: 38,
            iconSize: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white54 : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white30 : Colors.black26,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _PieData {
  final String category;
  final double value;
  final Color color;
  _PieData(this.category, this.value, this.color);
}
