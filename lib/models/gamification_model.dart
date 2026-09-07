class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int freezeTokens;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.freezeTokens,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] ?? json['streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? json['max_streak'] ?? 0,
      lastActivityDate: json['last_activity_date']?.toString(),
      freezeTokens: json['freeze_tokens'] ?? json['tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate,
      'freeze_tokens': freezeTokens,
    };
  }
}

class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String? icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? 'Insignia',
      description: json['description'] ?? '',
      icon: json['icon'],
      isUnlocked: json['is_unlocked'] ?? json['unlocked'] ?? (json['unlocked_at'] != null),
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'])
          : null,
    );
  }
}

class LeaderboardEntryModel {
  final int rank;
  final int userId;
  final String username;
  final String? fullName;
  final String? avatar;
  final int totalXp;
  final bool isCurrentUser;

  LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.username,
    this.fullName,
    this.avatar,
    required this.totalXp,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntryModel.fromJson(
    Map<String, dynamic> json, {
    int currentUserId = 0,
  }) {
    final uId = json['user_id'] ?? json['id'] ?? 0;
    return LeaderboardEntryModel(
      rank: json['rank'] ?? 0,
      userId: uId,
      username: json['username'] ?? 'Usuario',
      fullName: json['full_name'] ?? json['name'],
      avatar: json['avatar'],
      totalXp: json['total_xp'] ?? json['xp'] ?? 0,
      isCurrentUser: uId != 0 && uId == currentUserId,
    );
  }
}
