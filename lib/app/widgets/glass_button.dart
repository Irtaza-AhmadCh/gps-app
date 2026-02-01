import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import '../config/utils.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color accentColor;

  const GlassButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glassShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accentColor),

                if(label.isNotEmpty)
                  8.width,
                Text(
                  label,
                  style: AppTextStyle.bodyMedium.copyWith(
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
    );
  }
}
