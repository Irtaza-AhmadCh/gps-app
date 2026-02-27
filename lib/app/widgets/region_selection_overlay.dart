import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_colors.dart';

/// Overlay widget for drawing the selected region rectangle on the map.
///
/// Takes two LatLng corners and draws a semi-transparent colored rectangle.
/// Used as a stack overlay on top of FlutterMap.
class RegionSelectionOverlay extends StatelessWidget {
  final LatLng? start;
  final LatLng? end;

  const RegionSelectionOverlay({super.key, this.start, this.end});

  @override
  Widget build(BuildContext context) {
    if (start == null) {
      return const SizedBox.shrink();
    }

    // When only start is set, show a marker point
    if (end == null) {
      return Center(
        child: Container(
          width: 20.sp,
          height: 20.sp,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
        ),
      );
    }

    // When both are set, show a visual indicator that region is selected
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 16.sp),
            SizedBox(width: 8.sp),
            Expanded(
              child: Text(
                'Region selected — ready to download',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
