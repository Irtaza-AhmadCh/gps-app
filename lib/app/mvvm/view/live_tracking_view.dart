import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../../widgets/map_widget.dart';
import '../view_model/hike_tracking_controller.dart';

/// Live Tracking View - Real-time GPS tracking screen
class LiveTrackingView extends GetView<HikeTrackingController> {
  const LiveTrackingView({super.key});
  @override
  Widget build(BuildContext context) {
    // Auto-start tracking when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isTracking.value) {
        controller.startTracking();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.liveTracking,
          style: AppTextStyle.headlineMedium,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showStopConfirmation(context),
        ),
      ),
      body: Column(
        children: [
          // Map section
          Expanded(
            flex: 3,
            child: Obx(() {
              return MapWidget(
                points: controller.trackPoints,
                currentPoint: controller.currentLocation.value,
                showStartMarker: true,
                showCurrentMarker: true,
                mapController: controller.mapController,
              );
            }),
          ),

          // Stats panel
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Primary stats row
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Obx(
                          () => _buildStatColumn(
                            AppStrings.distance,
                            Utils.formatDistance(
                              controller.totalDistance.value,
                            ),
                            Icons.straighten,
                          ),
                        ),
                        Obx(
                          () => _buildStatColumn(
                            AppStrings.elevation,
                            Utils.formatElevation(
                              controller.elevationGain.value,
                            ),
                            Icons.trending_up,
                          ),
                        ),
                        Obx(
                          () => _buildStatColumn(
                            AppStrings.duration,
                            Utils.formatDuration(controller.duration.value),
                            Icons.timer,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Control buttons
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return ElevatedButton.icon(
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
                              backgroundColor: controller.isPaused.value
                                  ? AppColors.success
                                  : AppColors.warning,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              controller.stopTracking(saveHike: true),
                          icon: const Icon(Icons.stop),
                          label: Text(AppStrings.stop),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyle.statValue.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyle.statLabel, textAlign: TextAlign.center),
      ],
    );
  }

  void _showStopConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.discardHike),
        content: Text(AppStrings.confirmDiscard),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.stopTracking(saveHike: false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppStrings.discard),
          ),
        ],
      ),
    );
  }
}
