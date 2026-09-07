import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../models/course_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_sheet.dart';
import '../../widgets/gamification/glass_hud_bar.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // HUD Superior de Gamificación (Fuego, Racha, XP, Tema)
              const GlassHudBar(),

              // Cuerpo: Árbol de Aprendizaje en ruta sinuosa
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

                    final courses = provider.courses;
                    final userLevel = provider.user?.level ?? 1;

                    if (courses.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: GlassCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.explore_off_rounded,
                                  size: 48,
                                  color: AppColors.primaryOrange,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Camino en preparación',
                                  style: AppTextStyles.h3,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No hay lecciones disponibles por el momento. ¡Vuelve pronto!',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                GlassButton(
                                  text: 'Recargar',
                                  onPressed: () => provider.loadCourses(),
                                  variant: GlassButtonVariant.glass,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          provider.loadCourses(),
                          provider.loadStreak(),
                          provider.loadUserData(),
                        ]);
                      },
                      color: AppColors.primaryOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 16,
                          bottom: 110, // espacio para el floating navbar
                        ),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final isLocked = course.levelRequired > userLevel;
                          final isCompleted = course.isCompleted;
                          final isCurrent = !isLocked && !isCompleted;

                          // Alternar posición horizontal de los nodos (onda Duolingo)
                          // 0: centro-izq, 1: centro, 2: centro-der, 3: centro
                          final double horizontalOffset =
                              sin(index * 1.1) * 75.0;

                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          final nodeWidget = Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: Transform.translate(
                                offset: Offset(horizontalOffset, 0),
                                child: _buildPathNode(
                                  context: context,
                                  course: course,
                                  index: index,
                                  isLocked: isLocked,
                                  isCompleted: isCompleted,
                                  isCurrent: isCurrent,
                                  provider: provider,
                                ),
                              ),
                            ),
                          );

                          if (index == 0) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                                  child: GlassCard(
                                    borderRadius: BorderRadius.circular(22),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/mascota.png',
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '¡Anas wattakalu!',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppColors.darkText,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Avanza en tu camino de Wayuunaiki hoy.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : AppColors.lightText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                nodeWidget,
                              ],
                            );
                          }

                          return nodeWidget;
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

  Widget _buildPathNode({
    required BuildContext context,
    required CourseModel course,
    required int index,
    required bool isLocked,
    required bool isCompleted,
    required bool isCurrent,
    required AppProvider provider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color nodeBg;
    Gradient? borderGrad;
    IconData icon;
    Color iconColor;

    if (isLocked) {
      nodeBg = isDark
          ? Colors.white.withOpacity(0.04)
          : Colors.black.withOpacity(0.04);
      icon = Icons.lock_outline_rounded;
      iconColor = isDark ? Colors.white38 : Colors.black38;
      borderGrad = null;
    } else if (isCompleted) {
      nodeBg = AppColors.successGreen.withOpacity(isDark ? 0.35 : 0.25);
      icon = Icons.check_circle_rounded;
      iconColor = AppColors.successGreen;
      borderGrad = LinearGradient(
        colors: [AppColors.successGreen, AppColors.successGreen.withOpacity(0.3)],
      );
    } else {
      // Activo / En progreso
      nodeBg = AppColors.primaryOrange.withOpacity(isDark ? 0.90 : 0.92);
      icon = Icons.play_arrow_rounded;
      iconColor = Colors.white;
      borderGrad = LinearGradient(
        colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.2)],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón circular flotante (Node)
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showCourseModal(context, course, provider, isLocked);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anillo de resplandor para el nodo activo
              if (isCurrent)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

              // Contenedor principal de cristal
              GlassContainer(
                width: 74,
                height: 74,
                borderRadius: BorderRadius.circular(37),
                backgroundColor: nodeBg,
                borderGradient: borderGrad,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Icon(
                    icon,
                    size: 34,
                    color: iconColor,
                  ),
                ),
              ),

              // Insignia de nivel si está bloqueado
              if (isLocked)
                Positioned(
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'LVL ${course.levelRequired}',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),

              // Corona vectorial si está completado al 100%
              if (isCompleted)
                Positioned(
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppIcons.goldColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppIcons.goldColor, width: 1.2),
                    ),
                    child: const Icon(
                      AppIcons.crown,
                      color: AppIcons.goldColor,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Título del curso minimalista
        SizedBox(
          width: 140,
          child: Text(
            course.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              color: isLocked
                  ? (isDark ? Colors.white38 : Colors.black38)
                  : (isDark ? Colors.white : AppColors.darkText),
            ),
          ),
        ),
      ],
    );
  }

  void _showCourseModal(
    BuildContext context,
    CourseModel course,
    AppProvider provider,
    bool isLocked,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    GlassSheet.show(
      context: context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.withOpacity(0.2)
                      : AppColors.primaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isLocked ? Icons.lock_rounded : Icons.school_rounded,
                  color: isLocked ? Colors.grey : AppColors.primaryOrange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    Text(
                      'Nivel requerido: ${course.levelRequired} • ${course.estimatedDuration} min',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white60 : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            course.description.isNotEmpty
                ? course.description
                : 'Aprende los fundamentos del idioma Wayuunaiki a través de ejercicios prácticos y lecciones culturales interactivas.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? Colors.white70 : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),

          // Barra de progreso si está inscrito
          if (course.isEnrolled) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tu avance:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${course.userProgress.toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (course.userProgress / 100).clamp(0.0, 1.0),
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryOrange,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Botón de acción principal
          if (isLocked) ...[
            GlassButton(
              text: 'Nivel ${course.levelRequired} requerido',
              variant: GlassButtonVariant.glass,
              onPressed: null,
            ),
          ] else ...[
            GlassButton(
              text: course.isEnrolled ? 'Continuar Lección' : 'Comenzar Curso',
              icon: Icons.play_arrow_rounded,
              onPressed: () async {
                Navigator.pop(ctx);
                if (!course.isEnrolled) {
                  await provider.enrollCourse(course.id);
                }

                // Buscar quizzes del curso para abrir el ejercicio
                final courseQuizzes = provider.quizzes
                    .where((q) => q.course == course.id)
                    .toList();

                if (courseQuizzes.isNotEmpty && context.mounted) {
                  Navigator.pushNamed(
                    context,
                    '/quiz-attempt',
                    arguments: courseQuizzes.first,
                  );
                } else if (context.mounted) {
                  Navigator.pushNamed(context, '/quizzes');
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
