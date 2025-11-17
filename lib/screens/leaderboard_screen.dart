import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';
import '../widgets/empty_state.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _leaderboard = [];
  bool _isLoading = false;
  String _period = 'all'; // all, month, week

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getLeaderboard();
      setState(() {
        _leaderboard = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar clasificación: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AppProvider>().user;
    final currentUserRank = _leaderboard.indexWhere(
      (u) => u['id'] == currentUser?.id,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Clasificación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: Column(
        children: [
          // Posición del usuario actual
          if (currentUserRank >= 0 && currentUser != null)
            Container(
              padding: AppStyles.cardPadding,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                boxShadow: AppStyles.standardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.whiteText.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${currentUserRank + 1}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.whiteText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu posición',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.whiteText.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser.fullName,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.whiteText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteText.withOpacity(0.2),
                      borderRadius: AppStyles.smallBorderRadius,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${currentUser.xp} XP',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Nivel ${currentUser.level}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.whiteText.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Top 3
          if (_leaderboard.length >= 3) _buildTopThree(),

          // Lista completa
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  )
                : _leaderboard.isEmpty
                    ? const EmptyState(
                        icon: Icons.emoji_events_outlined,
                        title: 'Sin clasificación',
                        message: 'Aún no hay usuarios en la clasificación',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLeaderboard,
                        color: AppColors.primaryOrange,
                        child: ListView.builder(
                          padding: AppStyles.screenPadding,
                          itemCount: _leaderboard.length,
                          itemBuilder: (context, index) {
                            if (index < 3) return const SizedBox.shrink();
                            return _buildLeaderboardItem(
                              _leaderboard[index],
                              index,
                              currentUser?.id,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: AppColors.backgroundWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Segundo lugar
          if (_leaderboard.length >= 2)
            _buildPodiumItem(_leaderboard[1], 2, 110, AppColors.lightText),
          // Primer lugar
          _buildPodiumItem(_leaderboard[0], 1, 140, AppColors.warningYellow),
          // Tercer lugar
          if (_leaderboard.length >= 3)
            _buildPodiumItem(_leaderboard[2], 3, 90, AppColors.primaryOrange),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    Map<String, dynamic> user,
    int position,
    double height,
    Color color,
  ) {
    final name =
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: AppTextStyles.h2.copyWith(color: color),
                ),
              ),
            ),
            Positioned(
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  position == 1
                      ? Icons.emoji_events
                      : Icons.emoji_events_outlined,
                  color: AppColors.whiteText,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${user['xp'] ?? 0} XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    Map<String, dynamic> user,
    int index,
    int? currentUserId,
  ) {
    final name =
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final isCurrentUser = user['id'] == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryOrange.withOpacity(0.1)
            : AppColors.backgroundWhite,
        borderRadius: AppStyles.standardBorderRadius,
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primaryOrange
              : AppColors.lightText.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${index + 1}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
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
                  name.isEmpty ? 'Usuario' : name,
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
  }
}
