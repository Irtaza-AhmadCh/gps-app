import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gps/app/widgets/glass_container.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../../widgets/elevation_chart_widget.dart';
import '../../widgets/hike_stats_widget.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/glass_button.dart';
import '../view_model/hike_replay_controller.dart';

class HikeSummaryView extends GetView<HikeReplayController> {
  const HikeSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: controller.deleteHike,
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassBackground,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: PaddingExtension(const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                )).paddingAll(8),
              ),
            ),
            8.width,
          ],
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
                border: Border.all(
                  color: AppColors.glassBorder,
                ),
              ),
              child: const Icon(Icons.arrow_back),
            ),
            onPressed: (){
              Get.back();
            },
          ),
        ),
      ),


      body: Obx(() {
        final hike = controller.hike.value;
        if (hike == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return SingleChildScrollView(
          child: PaddingExtension(Column(
            children: [
              /// 🗺️ Map Replay
              GlassContainer(
                padding: EdgeInsets.all(5),

                height: 300,
                child: Obx(() {
                  final visiblePoints = hike.points.sublist(
                    0,
                    controller.currentIndex.value + 1,
                  );

                  return ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(16),
                    child: MapWidget(
                      points: visiblePoints,
                      currentPoint: controller.currentPoint,
                      showStartMarker: true,
                      showCurrentMarker: true,
                    ),
                  );
                }),
              ),

              16.height,

              /// 🎞️ Timeline Controls (Glass Card)
              GlassContainer(
                child: PaddingExtension(Column(
                  children: [
                    Row(
                      children: [
                        Obx(
                              () => GlassButton(
                            onTap: controller.togglePlayPause,
                            icon: controller.isPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            label: "",
                            accentColor: AppColors.primary,
                          ),
                        ),
                        4.width,
                        Expanded(
                          child: Obx(() {
                            final maxIndex = hike.points.length - 1;
                            return Slider(
                              value: controller.currentIndex.value
                                  .toDouble(),
                              min: 0,
                              max: maxIndex.toDouble(),
                              divisions: maxIndex > 0 ? maxIndex : 1,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.divider,
                              onChanged: (value) =>
                                  controller.scrubToIndex(value.toInt()),
                            );
                          }),
                        ),
                        4.width,
                        GlassButton(
                          onTap: controller.reset,
                          icon: Icons.replay,
                          label: "",
                          accentColor: AppColors.textSecondary,
                        ),
                      ],
                    ),

                    12.height,

                    /// Playback Stats
                    Obx(() {
                      final currentDist = controller.currentDistance;
                      final currentDur = controller.currentDuration;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(currentDist / 1000).toStringAsFixed(2)} km',
                            style: AppTextStyle.bodySmall,
                          ),
                          Text(
                            '${controller.currentIndex.value + 1} / ${hike.points.length}',
                            style: AppTextStyle.bodySmall,
                          ),
                          Text(
                            '${currentDur.inMinutes}:${(currentDur.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: AppTextStyle.bodySmall,
                          ),
                        ],
                      );
                    }),
                  ],
                )).paddingAll(16),
              ),

              24.height,

              /// 📊 Stats Summary (Already reusable – wrapped in glass)
              GlassContainer(
                child: PaddingExtension(HikeStatsWidget(
                  distance: hike.totalDistance,
                  elevationGain: hike.elevationGain,
                  elevationLoss: hike.elevationLoss,
                  duration: hike.duration,
                  avgSpeed: hike.averageSpeed,
                  maxElevation: hike.maxElevation,
                  minElevation: hike.minElevation,
                )).paddingAll(16),
              ),

              24.height,
            ],
          )).paddingAll(16),
        );
      }),
    );
  }
}
