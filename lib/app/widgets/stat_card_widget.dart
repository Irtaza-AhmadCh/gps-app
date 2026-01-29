import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import 'glass_container.dart';

/// Glassmorphic stat card widget
/// Displays an icon, value, and label for hike statistics
class StatCardWidget extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  const StatCardWidget({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyle.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
