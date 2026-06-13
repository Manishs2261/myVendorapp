import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.blur = 16.0,
    this.opacity = 0.04,
    this.color = Colors.white,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(24);
    
    return ClipRRect(
      borderRadius: defaultBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: defaultBorderRadius,
            border: border ?? Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: -8,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
