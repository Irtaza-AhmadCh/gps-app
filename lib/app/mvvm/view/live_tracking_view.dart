import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../../widgets/map_widget.dart';
import '../view_model/hike_tracking_controller.dart';

class LiveTrackingView extends GetView<HikeTrackingController> {
  const LiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          /// MAP
          Obx(
                () => MapWidget(
              points: controller.trackPoints,
              currentPoint: controller.currentLocation.value,
              showStartMarker: false,
              showCurrentMarker: true,
              mapController: controller.mapController,
            ),
          ),

          /// TOP STATUS (ONLY WHEN TRACKING)
          Obx(
                () => controller.isTracking.value
                ? SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: _glassDecoration(),
                child: Text(
                  Utils.formatDuration(controller.duration.value),
                  style: AppTextStyle.headlineMedium,
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),

          /// BOTTOM CONTROL PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
                  () => Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: _glassDecoration(),
                child: controller.isTracking.value
                    ? _trackingControls()
                    : _startHikeButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ▶️ Start Hike
  Widget _startHikeButton() {
    return ElevatedButton(
      onPressed: controller.startTracking,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: const StadiumBorder(),
      ),
      child: Text(
        AppStrings.startHike,
        style: AppTextStyle.button,
      ),
    );
  }

  /// ⏸️ Controls
  Widget _trackingControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// STATS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              AppStrings.distance,
              Utils.formatDistance(controller.totalDistance.value),
            ),
            _statItem(
              AppStrings.duration,
              Utils.formatDuration(controller.duration.value),
            ),
          ],
        ),
        const SizedBox(height: 16),

        /// BUTTONS
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isPaused.value
                    ? controller.resumeTracking
                    : controller.pauseTracking,
                icon: Icon(
                  controller.isPaused.value
                      ? Icons.play_arrow
                      : Icons.pause,
                ),
                label: Text(
                  controller.isPaused.value
                      ? AppStrings.resume
                      : AppStrings.pause,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.stopTracking,
                icon: const Icon(Icons.stop),
                label: Text(AppStrings.stop),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyle.statValue),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyle.statLabel),
      ],
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: AppColors.surface.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }
}
