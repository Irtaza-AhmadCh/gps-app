import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import '../config/utils.dart';
import '../mvvm/model/slope_segment.dart';
import 'glass_container.dart';

/// Compact slope difficulty legend overlay for the map.
/// Shows color-coded difficulty levels.
class SlopeLegendWidget extends StatelessWidget {
  const SlopeLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      borderRadius: 10.sp,
      blur: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Slope',
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          6.height,
          ...SlopeDifficulty.values.map(
            (d) => Padding(
              padding: EdgeInsets.only(bottom: 3.sp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.sp,
                    height: 12.sp,
                    decoration: BoxDecoration(
                      color: d.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  6.width,
                  Text(
                    d.range,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.platinum,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
