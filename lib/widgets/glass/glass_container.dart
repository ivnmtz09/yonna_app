import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? borderGradient;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderGradient,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = AppTheme.glass(context);
    final rRadius = borderRadius ?? BorderRadius.circular(20);
    final effectiveBlur = blur ?? glassTheme.blurSigma;
    final effectiveBg = backgroundColor ?? glassTheme.cardBackground;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: rRadius,
      ),
      child: child,
    );

    // Borde con degradado de cristal
    Widget borderedContent = Container(
      decoration: BoxDecoration(
        borderRadius: rRadius,
        gradient: borderGradient ?? glassTheme.borderGradient,
        boxShadow: boxShadow ?? glassTheme.glassShadow,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipRRect(
        borderRadius: rRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: content,
        ),
      ),
    );

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: borderedContent,
      );
    }

    return borderedContent;
  }
}
