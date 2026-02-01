import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide WidgetPaddingX;
import 'package:gps/app/widgets/glass_container.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/map_widget.dart';
import '../view_model/hike_tracking_controller.dart';

class LiveTrackingView extends GetView<HikeTrackingController> {
  const LiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isTracking.value) {
        controller.initializeLocationService();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorder, width: 1),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,

                title: Text(
                  AppStrings.liveTracking,
                  style: AppTextStyle.headlineMedium.copyWith(
                    letterSpacing: 0.8,
                  ),
                ),

                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glassBackground,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Center(child: const Icon(Icons.arrow_back)),
                  ),
                  onPressed: _showStopConfirmation,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          /// Map Section
          Expanded(
            flex: 3,
            child: Obx(
              () => MapWidget(
                points: controller.trackPoints,
                currentPoint: controller.currentLocation.value,
                showStartMarker: true,
                showCurrentMarker: true,
                mapController: controller.mapController,
              ),
            ),
          ),

          /// Stats & Controls
          Expanded(
            flex: 2,
            child: GlassContainer(
              child: Column(
                children: [
                  16.height,

                  /// Stats
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Obx(
                          () => _StatItem(
                            icon: Icons.straighten,
                            label: AppStrings.distance,
                            value: Utils.formatDistance(
                              controller.totalDistance.value,
                            ),
                          ),
                        ),
                        Obx(
                          () => _StatItem(
                            icon: Icons.trending_up,
                            label: AppStrings.elevation,
                            value: Utils.formatElevation(
                              controller.elevationGain.value,
                            ),
                          ),
                        ),
                        Obx(
                          () => _StatItem(
                            icon: Icons.timer,
                            label: AppStrings.duration,
                            value: Utils.formatDuration(
                              controller.duration.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  12.height,

                  // Controls
                  Obx(() {
                    if (!controller.isHikeStarted.value) {
                      // START BUTTON
                      return GlassButton(
                        onTap: () {
                          if (controller.isGpsReady.value) {
                            controller.startHikeRecording();
                          }
                        }, // Disabled until GPS ready
                        icon: Icons.play_arrow_rounded,
                        label: controller.isGpsReady.value
                            ? AppStrings.startHike
                            : 'Waiting for GPS...',
                        accentColor: controller.isGpsReady.value
                            ? AppColors.primary
                            : Colors.grey,
                      ).paddingSymmetric(horizontal: 16);
                    } else {
                      // PAUSE / RESUME / STOP
                      return Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              onTap: controller.isPaused.value
                                  ? controller.resumeTracking
                                  : controller.pauseTracking,
                              icon: controller.isPaused.value
                                  ? Icons.play_arrow
                                  : Icons.pause,
                              label: controller.isPaused.value
                                  ? AppStrings.resume
                                  : AppStrings.pause,
                              accentColor: AppColors.primary,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: GlassButton(
                              onTap: () =>
                                  controller.stopTracking(saveHike: true),
                              icon: Icons.stop,
                              label: AppStrings.stop,
                              accentColor: AppColors.error,
                            ),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16);
                    }
                  }),

                  16.height,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStopConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.discardHike),
        content: Text(AppStrings.confirmDiscard),
        actions: [
          TextButton(onPressed: Get.back, child: Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              Get.back();
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

/// Reusable Stat Widget (UI-only)
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassBackground,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: PaddingExtension(
            Icon(icon, color: AppColors.primary, size: 22),
          ).paddingAll(10),
        ),
        8.height,
        Text(value, style: AppTextStyle.statValue.copyWith(letterSpacing: 0.8)),
        4.height,
        Text(label, style: AppTextStyle.statLabel),
      ],
    );
  }
}
