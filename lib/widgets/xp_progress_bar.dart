import 'package:flutter/material.dart';
import 'app_styles.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int xpForNextLevel;
  final int currentLevel;

  const XpProgressBar({
    Key? key,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.currentLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (currentXp % xpForNextLevel) / xpForNextLevel;
    final xpInLevel = currentXp % xpForNextLevel;

    return Container(
      padding: AppStyles.cardPadding,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel $currentLevel',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
              Text(
                '$xpInLevel / $xpForNextLevel XP',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingS),
          ClipRRect(
            borderRadius: AppStyles.smallBorderRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.backgroundGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
