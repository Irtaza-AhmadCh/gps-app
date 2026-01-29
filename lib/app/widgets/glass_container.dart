import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? AppColors.glassBackground).withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.glassBorder.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
