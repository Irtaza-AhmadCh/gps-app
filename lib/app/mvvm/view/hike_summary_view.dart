import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../widgets/elevation_chart_widget.dart';
import '../../widgets/hike_stats_widget.dart';
import '../../widgets/map_widget.dart';
import '../view_model/hike_replay_controller.dart';

/// Hike Summary View - Displays completed hike with replay functionality
class HikeSummaryView extends GetView<HikeReplayController> {
  const HikeSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.hike.value?.name ?? AppStrings.hikeSummary,
            style: AppTextStyle.headlineMedium,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: controller.deleteHike,
          ),
        ],
      ),
      body: Obx(() {
        final hike = controller.hike.value;
        if (hike == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Map section with replay
              SizedBox(
                height: 300,
                child: Obx(() {
                  final currentPoint = controller.currentPoint;
                  final visiblePoints = hike.points.sublist(
                    0,
                    controller.currentIndex.value + 1,
                  );

                  return MapWidget(
                    points: visiblePoints,
                    currentPoint: currentPoint,
                    showStartMarker: true,
                    showCurrentMarker: true,
                  );
                }),
              ),

              // Timeline slider
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              controller.isPlaying.value
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            onPressed: controller.togglePlayPause,
                          ),
                        ),
                        Expanded(
                          child: Obx(() {
                            final maxIndex = hike.points.length - 1;
                            return Slider(
                              value: controller.currentIndex.value.toDouble(),
                              min: 0,
                              max: maxIndex.toDouble(),
                              divisions: maxIndex > 0 ? maxIndex : 1,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.divider,
                              onChanged: (value) {
                                controller.scrubToIndex(value.toInt());
                              },
                            );
                          }),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.replay,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: controller.reset,
                        ),
                      ],
                    ),
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
                ),
              ),

              // Container(
              //   height: 200,
              //   padding: const EdgeInsets.all(16),
              //   child: Obx(() {
              //     final elevations = controller.smoothedElevations;
              //     // Calculate cumulative distances for each point
              //     final distances = <double>[];
              //     for (int i = 0; i < hike.points.length; i++) {
              //       distances.add(controller.currentDistance);
              //     }
              //
              //     return ElevationChartWidget(
              //       elevations: elevations,
              //       distances: distances,
              //       currentIndex: controller.currentIndex.value,
              //       onPointTapped: (index) {
              //         controller.scrubToIndex(index);
              //       },
              //     );
              //   }),
              // ),

              // Stats summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: HikeStatsWidget(
                  distance: hike.totalDistance,
                  elevationGain: hike.elevationGain,
                  elevationLoss: hike.elevationLoss,
                  duration: hike.duration,
                  avgSpeed: hike.averageSpeed,
                  maxElevation: hike.maxElevation,
                  minElevation: hike.minElevation,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
