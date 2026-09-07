import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icons.dart';
import '../../models/gamification_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/common/glass_icon_badge.dart';
import '../../widgets/gamification/glass_hud_bar.dart';

class GlassLeaderboardScreen extends StatefulWidget {
  const GlassLeaderboardScreen({super.key});

  @override
  State<GlassLeaderboardScreen> createState() => _GlassLeaderboardScreenState();
}

class _GlassLeaderboardScreenState extends State<GlassLeaderboardScreen> {
  int _selectedTab = 0; // 0: Clasificación, 1: Insignias

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadLeaderboard();
      provider.loadBadges();
      provider.loadStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Barra HUD Superior
              const GlassHudBar(),

              // Switcher de Pestañas: Liga vs Insignias
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: GlassContainer(
                  height: 46,
                  borderRadius: BorderRadius.circular(23),
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.85),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(0, AppIcons.trophy, 'Liga Global', isDark),
                      ),
                      Expanded(
                        child: _buildTabButton(1, AppIcons.badge, 'Insignias', isDark),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido según pestaña
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          provider.loadLeaderboard(),
                          provider.loadBadges(),
                          provider.loadStreak(),
                        ]);
                      },
                      color: AppColors.primaryOrange,
                      child: _selectedTab == 0
                          ? _buildLeaderboardView(provider, isDark)
                          : _buildBadgesView(provider, isDark),
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

  Widget _buildTabButton(int index, IconData icon, String title, bool isDark) {
    final isSelected = _selectedTab == index;

    return InkWell(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withValues(alpha: isDark ? 0.35 : 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primaryOrange
                  : (isDark ? Colors.white60 : AppColors.lightText),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryOrange
                    : (isDark ? Colors.white60 : AppColors.lightText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardView(AppProvider provider, bool isDark) {
    final list = provider.leaderboard;

    if (list.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay puntuaciones en la liga.',
          style: TextStyle(color: isDark ? Colors.white60 : AppColors.lightText),
        ),
      );
    }

    final top1 = list.isNotEmpty ? list[0] : null;
    final top2 = list.length > 1 ? list[1] : null;
    final top3 = list.length > 2 ? list[2] : null;
    final remaining = list.length > 3 ? list.sublist(3) : <LeaderboardEntryModel>[];

    // Buscar la entrada del usuario actual
    final currentUserId = provider.user?.id ?? 0;
    final userRankItem = list.firstWhere(
      (e) => e.userId == currentUserId,
      orElse: () => LeaderboardEntryModel(
        rank: 0,
        userId: currentUserId,
        username: provider.user?.firstName ?? 'Tú',
        totalXp: provider.user?.xp ?? 0,
        isCurrentUser: true,
      ),
    );

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 170),
          children: [
            // Podio de cristal para los puestos 1, 2 y 3
            _buildPodium(top1: top1, top2: top2, top3: top3, isDark: isDark),
            const SizedBox(height: 20),

            // Filas de clasificación (4 en adelante)
            ...remaining.map((entry) => _buildLeaderboardRow(entry, isDark)),
          ],
        ),

        // Tarjeta adhesiva en la parte inferior para la posición del usuario
        Positioned(
          left: 16,
          right: 16,
          bottom: 96, // Justo sobre el GlassNavBar
          child: GlassCard(
            borderRadius: BorderRadius.circular(20),
            backgroundColor: AppColors.primaryOrange.withOpacity(isDark ? 0.35 : 0.22),
            borderGradient: LinearGradient(
              colors: [
                AppColors.primaryOrange,
                AppColors.primaryOrange.withOpacity(0.3),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Text(
                  userRankItem.rank > 0 ? '#${userRankItem.rank}' : '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(width: 14),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryOrange,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tu posición actual',
                        style: TextStyle(fontSize: 11, color: AppColors.primaryOrange),
                      ),
                      Text(
                        userRankItem.username,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${userRankItem.totalXp} XP',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodium({
    LeaderboardEntryModel? top1,
    LeaderboardEntryModel? top2,
    LeaderboardEntryModel? top3,
    required bool isDark,
  }) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Puesto 2 (Plata)
          if (top2 != null)
            Expanded(
              child: _buildPodiumPillar(
                top2,
                height: 110,
                color: AppIcons.silverColor,
                medalIcon: AppIcons.medalSilver,
                isDark: isDark,
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 8),

          // Puesto 1 (Oro)
          if (top1 != null)
            Expanded(
              child: _buildPodiumPillar(
                top1,
                height: 145,
                color: AppIcons.goldColor,
                medalIcon: AppIcons.crown,
                isDark: isDark,
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 8),

          // Puesto 3 (Bronce)
          if (top3 != null)
            Expanded(
              child: _buildPodiumPillar(
                top3,
                height: 90,
                color: AppIcons.bronzeColor,
                medalIcon: AppIcons.medalBronze,
                isDark: isDark,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPodiumPillar(
    LeaderboardEntryModel entry, {
    required double height,
    required Color color,
    required IconData medalIcon,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIconBadge(
          icon: medalIcon,
          color: color,
          size: 38,
          iconSize: 20,
          borderRadius: 19,
        ),
        const SizedBox(height: 6),
        Text(
          entry.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkText,
          ),
        ),
        Text(
          '${entry.totalXp} XP',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntryModel entry, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white54 : AppColors.lightText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
              child: Text(
                entry.username.isNotEmpty ? entry.username[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.username,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.darkText,
                ),
              ),
            ),
            Text(
              '${entry.totalXp} XP',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesView(AppProvider provider, bool isDark) {
    final badges = provider.badges;

    if (badges.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay insignias desbloqueadas. ¡Completa quizzes para ganarlas!',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white60 : AppColors.lightText),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      gridDelegate: const dynamic_sliver_grid_delegate(),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isUnlocked = badge.isUnlocked;

        return GlassCard(
          borderRadius: BorderRadius.circular(20),
          backgroundColor: isUnlocked
              ? AppColors.primaryOrange.withOpacity(isDark ? 0.22 : 0.12)
              : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassIconBadge(
                icon: isUnlocked ? AppIcons.badge : Icons.lock_outline_rounded,
                color: isUnlocked
                    ? AppIcons.goldColor
                    : (isDark ? Colors.white38 : Colors.black38),
                size: 52,
                iconSize: 28,
                borderRadius: 26,
              ),
              const SizedBox(height: 10),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? (isDark ? Colors.white : AppColors.darkText)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : AppColors.lightText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class dynamic_sliver_grid_delegate extends SliverGridDelegateWithFixedCrossAxisCount {
  const dynamic_sliver_grid_delegate()
      : super(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        );
}
