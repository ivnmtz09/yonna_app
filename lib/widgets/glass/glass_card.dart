import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_container.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Gradient? borderGradient;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderGradient,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final rRadius = borderRadius ?? BorderRadius.circular(20);

    Widget cardBody = GlassContainer(
      width: width,
      height: height,
      padding: EdgeInsets.zero,
      borderRadius: rRadius,
      backgroundColor: backgroundColor,
      borderGradient: borderGradient,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: rRadius,
          splashColor: Colors.white.withOpacity(0.12),
          highlightColor: Colors.white.withOpacity(0.06),
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          onLongPress: onLongPress != null
              ? () {
                  HapticFeedback.mediumImpact();
                  onLongPress!();
                }
              : null,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: cardBody,
      );
    }

    return cardBody;
  }
}
