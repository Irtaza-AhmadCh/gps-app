import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../../widgets/custom_button.dart';
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

          /// WAITING FOR GPS OVERLAY
          Obx(() {
            if (!controller.gpsReady.value && !controller.isTracking.value) {
              return Center(
                child: Container(// use your extension
                  decoration: BoxDecoration(
                    color: AppColors.mapPlaceholder,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed,
                          size: 48, color: AppColors.mapPlaceholderText),
                      12.height,
                      Text(
                        "Waiting for GPS signal...",
                        style: TextStyle(
                          color: AppColors.mapPlaceholderText,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

        ],
      ),
    );
  }

  /// ▶️ Start Hike
  Widget _startHikeButton() {
    return Obx(
          () => CustomButton(

        text: !controller.gpsReady.value ? "Waiting" : AppStrings.startHike,
        onTap: controller.gpsReady.value ? controller.startTracking : (){
          Get.snackbar("Waiting for GPS", "Please wait for GPS to be ready", snackPosition: SnackPosition.TOP);
        },
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
              child: CustomButton(
                text: controller.isPaused.value ? AppStrings.resume.tr : AppStrings.pause.tr,
                icon: Icon( controller.isPaused.value ? Icons.play_arrow : Icons.pause),
                onTap: controller.isPaused.value ? controller.resumeTracking : controller.pauseTracking,
              ),
            ),
            12.width,
            Expanded(
              child: CustomButton(
                text: AppStrings.stop.tr,
                icon:  Icon(Icons.stop),
                onTap: controller.stopTracking,
              ),
            ),
          ],
        )

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
