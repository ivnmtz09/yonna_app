import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_styles.dart';
import 'glass_container.dart';

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassTheme = AppTheme.glass(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: GlassContainer(
          height: 68,
          borderRadius: BorderRadius.circular(34),
          backgroundColor: glassTheme.floatingNavBackground,
          borderGradient: glassTheme.borderGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return InkWell(
                onTap: () {
                  if (!isSelected) {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  }
                },
                borderRadius: BorderRadius.circular(24),
                splashColor: AppColors.primaryOrange.withOpacity(0.15),
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 14 : 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryOrange.withOpacity(isDark ? 0.22 : 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected
                            ? AppColors.primaryOrange
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
