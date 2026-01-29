import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../config/utils.dart';
import '../../widgets/glass_container.dart';
import '../view_model/hikes_list_view_model.dart';

/// Hikes List View - Browse all saved hikes
class HikesListView extends GetView<HikesListViewModel> {
  const HikesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.myHikes, style: AppTextStyle.headlineLarge),
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
        if (controller.hikes.isEmpty) {
          return _buildEmptyState();
        }

        // Show hikes list
        return _buildHikesList();
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.startNewHike,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.eerieBlack,
        icon: const Icon(Icons.add_location),
        label: Text(AppStrings.startHike, style: AppTextStyle.button),
      ),
    );
  }

  Widget _buildPermissionBanner() {
    return Center(
      child: GlassContainer(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
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
                foregroundColor: AppColors.eerieBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
            AppStrings.noHikesMessage,
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
        itemCount: controller.hikes.length,
        itemBuilder: (context, index) {
          final hike = controller.hikes[index];
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () => controller.viewHikeDetails(hike),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mock header image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      'https://images.pexels.com/photos/618833/pexels-photo-618833.jpeg',
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.landscape,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Hike info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hike.name,
                                style: AppTextStyle.headlineSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Utils.formatDateTime(hike.startTime),
                          style: AppTextStyle.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatChip(
                              Icons.straighten,
                              Utils.formatDistance(hike.totalDistance),
                            ),
                            _buildStatChip(
                              Icons.timer,
                              Utils.formatDuration(hike.duration),
                            ),
                            _buildStatChip(
                              Icons.trending_up,
                              Utils.formatElevationSimple(hike.elevationGain),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
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
