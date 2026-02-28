import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide WidgetPaddingX;
import 'package:gps/app/widgets/glass_container.dart';
import '../../widgets/app_bars.dart';
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
              child: CustomAppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: AppStrings.liveTracking,
                showBackButton: true,
                onBackTap: _showStopConfirmation,
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
            child: Stack(
              children: [
                Obx(
                  () => MapWidget(
                    points: controller.trackPoints,
                    currentPoint: controller.currentLocation.value,
                    showStartMarker: true,
                    showCurrentMarker: true,
                    mapController: controller.mapController,
                    onTap: (tapPosition, point) => controller.onMapTap(point),
                    showSlopeColoring: controller.showSlopeColoring.value,
                    slopeSegments: controller.slopeSegments,
                    showSlopeLegend: controller.showSlopeColoring.value,
                    onSlopeToggle: (value) {
                      if (controller.showSlopeColoring.value != value) {
                        controller.toggleSlopeColoring();
                      }
                    },
                    extraLayers: [
                      if (controller.isDownloadMode.value &&
                          controller.selectionStart.value != null &&
                          controller.selectionEnd.value != null)
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: controller.getPolygonPoints(),
                              color: AppColors.primary.withOpacity(0.15),
                              borderColor: AppColors.primary,
                              borderStrokeWidth: 2,
                              isFilled: true,
                            ),
                          ],
                        ),
                      if (controller.isDownloadMode.value &&
                          controller.selectionStart.value != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: controller.selectionStart.value!,
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            if (controller.selectionEnd.value != null)
                              Marker(
                                point: controller.selectionEnd.value!,
                                width: 20,
                                height: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Download Mode Overlay Hints and Controls
                Obx(() {
                  if (!controller.isDownloadMode.value)
                    return const SizedBox.shrink();
                  String hint;
                  if (controller.selectionStart.value == null) {
                    hint = 'Tap to set first corner';
                  } else if (controller.selectionEnd.value == null) {
                    hint = 'Tap to set second corner';
                  } else {
                    hint = 'Ready to download';
                  }
                  return Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      borderRadius: 10,
                      blur: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hint,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.bodySmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          if (controller.hasCompleteSelection) ...[
                            8.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '${controller.estimatedTiles.value} tiles',
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  controller.estimatedSize.value,
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            12.height,
                            Row(
                              children: [
                                Expanded(
                                  child: GlassButton(
                                    onTap: controller.cancelDownloadMode,
                                    label: 'Cancel',
                                  ),
                                ),
                                12.width,
                                Expanded(
                                  child: GlassButton(
                                    onTap: () =>
                                        _showDownloadBottomSheet(context),
                                    label: 'Download',
                                    accentColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

                // Download Progress Overlay
                Obx(() {
                  if (!controller.isDownloading.value)
                    return const SizedBox.shrink();
                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 16,
                        blur: 12,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: controller.downloadProgress.value,
                              color: AppColors.primary,
                            ),
                            16.height,
                            Text(
                              '${(controller.downloadProgress.value * 100).toInt()}%',
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            8.height,
                            Text(
                              'Downloading...',
                              style: AppTextStyle.bodySmall.copyWith(
                                color: AppColors.platinum,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Map Actions (Floating right side)
                Obx(() {
                  if (controller.isDownloadMode.value)
                    return const SizedBox.shrink();
                  return Positioned(
                    right: 16,
                    top: 80, // below MapSkinSwitcher
                    child: GestureDetector(
                      onTap: controller.startDownloadMode,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 12,
                        blur: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.download_for_offline_outlined,
                              color: AppColors.white,
                              size: 18,
                            ),
                            6.width,
                            Text(
                              'Offline',
                              style: AppTextStyle.bodySmall.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
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

  void _showDownloadBottomSheet(BuildContext context) {
    final textController = TextEditingController();
    Get.bottomSheet(
      GlassContainer(
        borderRadius: 24,
        blur: 12,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save Offline Region',
                style: AppTextStyle.headlineMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              16.height,
              TextField(
                controller: textController,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Region Name',
                  hintStyle: TextStyle(color: AppColors.dimGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.dimGrey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              24.height,
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onTap: () => Get.back(),
                      label: 'Cancel',
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: GlassButton(
                      onTap: () {
                        final name = textController.text.trim();
                        if (name.isNotEmpty) {
                          Get.back();
                          controller.downloadRegion(name);
                        }
                      },
                      label: 'Save',
                      accentColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              16.height,
            ],
          ),
        ),
      ),
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
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
