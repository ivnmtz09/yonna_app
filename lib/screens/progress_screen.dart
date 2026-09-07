import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../core/constants/app_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/glass/glass_background.dart';
import '../widgets/glass/glass_card.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/common/glass_icon_badge.dart';

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
                      'Mi Progreso y Métricas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido con gráfico Syncfusion y estadísticas
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.progress.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOrange,
                        ),
                      );
                    }

                    final user = provider.user;
                    final totalXp = user?.xp ?? 0;
                    final streak = provider.currentStreak;
                    final progressList = provider.progress;

                    return RefreshIndicator(
                      onRefresh: () => provider.loadProgress(),
                      color: AppColors.primaryOrange,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Resumen de KPIs
                            Row(
                              children: [
                                Expanded(
                                  child: GlassCard(
                                    borderRadius: BorderRadius.circular(18),
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const GlassIconBadge(
                                          icon: AppIcons.xp,
                                          color: AppIcons.xpColor,
                                          size: 36,
                                          iconSize: 20,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '$totalXp XP',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Experiencia Total',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.white54 : AppColors.lightText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GlassCard(
                                    borderRadius: BorderRadius.circular(18),
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const GlassIconBadge(
                                          icon: AppIcons.streak,
                                          color: AppIcons.streakColor,
                                          size: 36,
                                          iconSize: 20,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '$streak días',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Racha Consecutiva',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.white54 : AppColors.lightText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 2. Gráfico Syncfusion: Curva de Actividad y XP
                            GlassCard(
                              borderRadius: BorderRadius.circular(22),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.show_chart_rounded,
                                        color: AppColors.primaryOrange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Curva Semanal de XP',
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
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      margin: EdgeInsets.zero,
                                      primaryXAxis: CategoryAxis(
                                        majorGridLines: const MajorGridLines(width: 0),
                                        labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.white54 : AppColors.lightText,
                                        ),
                                      ),
                                      primaryYAxis: NumericAxis(
                                        isVisible: false,
                                        majorGridLines: const MajorGridLines(width: 0),
                                      ),
                                      tooltipBehavior: TooltipBehavior(enable: true),
                                      series: <CartesianSeries<_ChartData, String>>[
                                        SplineAreaSeries<_ChartData, String>(
                                          dataSource: _getWeeklySampleData(totalXp),
                                          xValueMapper: (_ChartData data, _) => data.day,
                                          yValueMapper: (_ChartData data, _) => data.xp,
                                          name: 'XP',
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primaryOrange.withValues(alpha: 0.4),
                                              AppColors.primaryOrange.withValues(alpha: 0.0),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderColor: AppColors.primaryOrange,
                                          borderWidth: 2.5,
                                          markerSettings: const MarkerSettings(
                                            isVisible: true,
                                            shape: DataMarkerType.circle,
                                            color: AppColors.primaryOrange,
                                            borderColor: Colors.white,
                                            borderWidth: 2,
                                            width: 6,
                                            height: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 3. Cursos Inscritos y Progreso
                            Text(
                              'CURSOS EN PROGRESO',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.white60 : AppColors.lightText,
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (progressList.isEmpty)
                              GlassCard(
                                borderRadius: BorderRadius.circular(18),
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    'Inscríbete en una lección del camino de aprendizaje para ver tu avance detallado.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white60 : AppColors.lightText,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...progressList.map((prog) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GlassCard(
                                    borderRadius: BorderRadius.circular(18),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                prog.courseTitle,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : AppColors.darkText,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: prog.courseCompleted
                                                    ? AppColors.successGreen.withValues(alpha: 0.2)
                                                    : AppColors.primaryOrange.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${(prog.percentage * 100).toInt()}%',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: prog.courseCompleted
                                                      ? AppColors.successGreen
                                                      : AppColors.primaryOrange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: prog.percentage,
                                            backgroundColor: isDark
                                                ? Colors.white.withValues(alpha: 0.08)
                                                : Colors.black.withValues(alpha: 0.06),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              prog.courseCompleted
                                                  ? AppColors.successGreen
                                                  : AppColors.primaryOrange,
                                            ),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
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

  List<_ChartData> _getWeeklySampleData(int totalXp) {
    // Genera una curva armónica basada en el XP actual del usuario
    final base = (totalXp / 7).clamp(10, 300).toDouble();
    return [
      _ChartData('Lun', base * 0.4),
      _ChartData('Mar', base * 0.7),
      _ChartData('Mié', base * 0.5),
      _ChartData('Jue', base * 1.1),
      _ChartData('Vie', base * 0.9),
      _ChartData('Sáb', base * 1.3),
      _ChartData('Hoy', base * 1.5),
    ];
  }
}

class _ChartData {
  final String day;
  final double xp;
  _ChartData(this.day, this.xp);
}
