import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../view_model/home_controller.dart';

/// Home View - Main screen showing saved hikes and start button
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.homeTitle, style: AppTextStyle.headlineLarge),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Obx(() {
        // Show permission banner if GPS not granted
        if (!controller.hasGpsPermission.value) {
          return _buildPermissionBanner();
        }

        // Show loading indicator
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Show empty state
        if (controller.savedHikes.isEmpty) {
          return _buildEmptyState();
        }

        // Show hikes list
        return _buildHikesList();
      }),
      floatingActionButton: Obx(() {
        return FloatingActionButton.extended(
          onPressed: controller.hasGpsPermission.value
              ? controller.startNewHike
              : controller.requestPermission,
          backgroundColor: AppColors.primary,
          icon: Icon(
            controller.hasGpsPermission.value
                ? Icons.add_location
                : Icons.location_off,
            color: AppColors.textPrimary,
          ),
          label: Text(
            controller.hasGpsPermission.value
                ? AppStrings.startHike
                : AppStrings.enableGps,
            style: AppTextStyle.button,
          ),
        );
      }),
    );
  }

  Widget _buildPermissionBanner() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(
              AppStrings.gpsPermissionRequired,
              style: AppTextStyle.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.requestPermission,
              icon: const Icon(Icons.location_on),
              label: Text(AppStrings.enableGps),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hiking,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noHikesYet,
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHikesList() {
    return RefreshIndicator(
      onRefresh: controller.refreshHikes,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.savedHikes.length,
        itemBuilder: (context, index) {
          final hike = controller.savedHikes[index];
          return Dismissible(
            key: Key(hike.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await Get.dialog<bool>(
                AlertDialog(
                  title: Text(AppStrings.deleteHike),
                  content: Text(AppStrings.confirmDelete),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(AppStrings.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: Text(AppStrings.delete),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              controller.deleteHike(hike.id);
            },
            child: Card(
              color: AppColors.glassBackground,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => controller.viewHikeSummary(hike),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.hiking,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hike.name,
                              style: AppTextStyle.headlineSmall,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        Utils.formatDateTime(hike.startTime),
                        style: AppTextStyle.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHikeStatChip(
                            Icons.straighten,
                            Utils.formatDistance(hike.totalDistance),
                          ),
                          _buildHikeStatChip(
                            Icons.timer,
                            Utils.formatDuration(hike.duration),
                          ),
                          _buildHikeStatChip(
                            Icons.trending_up,
                            Utils.formatElevationSimple(hike.elevationGain),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHikeStatChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyle.bodySmall),
      ],
    );
  }
}
