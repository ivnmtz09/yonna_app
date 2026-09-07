import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'glass_container.dart';

class GlassSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const GlassSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = AppTheme.glass(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        child: GlassContainer(
          borderRadius: borderRadius ?? BorderRadius.circular(28),
          backgroundColor: glassTheme.cardBackground,
          borderGradient: glassTheme.borderGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Asa superior (handle)
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (ctx) => GlassSheet(child: builder(ctx)),
    );
  }
}
