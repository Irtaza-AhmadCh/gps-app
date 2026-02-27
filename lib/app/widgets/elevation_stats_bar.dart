import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import '../config/utils.dart';
import '../mvvm/model/elevation_profile_data.dart';
import 'glass_container.dart';

/// Compact elevation statistics bar widget.
/// Displays total ascent, descent, max, and min elevation in a row.
class ElevationStatsBar extends StatelessWidget {
  final ElevationProfileData profileData;

  const ElevationStatsBar({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
      borderRadius: 12.sp,
      blur: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.trending_up,
            iconColor: AppColors.elevationGain,
            label: 'Ascent',
            value: '${profileData.totalAscent.toStringAsFixed(0)}m',
          ),
          _StatItem(
            icon: Icons.trending_down,
            iconColor: AppColors.elevationLoss,
            label: 'Descent',
            value: '${profileData.totalDescent.toStringAsFixed(0)}m',
          ),
          _StatItem(
            icon: Icons.arrow_upward,
            iconColor: AppColors.primary,
            label: 'Max',
            value: '${profileData.maxElevation.toStringAsFixed(0)}m',
          ),
          _StatItem(
            icon: Icons.arrow_downward,
            iconColor: AppColors.info,
            label: 'Min',
            value: '${profileData.minElevation.toStringAsFixed(0)}m',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16.sp),
        4.height,
        Text(
          value,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
        2.height,
        Text(
          label,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.platinum,
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
