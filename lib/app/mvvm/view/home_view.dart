import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../../widgets/app_bars.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_cached_image.dart';
import '../view_model/home_controller.dart';

/// Home View - Redesigned Dashboard
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBackButton: false,
        titleWidget: _buildProfileHeader(),
        actions: [
          IconButton(
            onPressed: () {
              // Get.toNamed(AppRoutes.notificationView);
              // Route generic until implemented or assuming AppRoutes exists
            },
            icon: GlassContainer(
              padding: EdgeInsets.all(8.sp),
              borderRadius: 30,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.white,
              ),
            ),
          ),
          16.width,
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🏞️ Image Slider
            _buildImageSlider(),

            24.height,

            /// 📊 Stats Section
            _buildStatsSection(),

            24.height,

            /// 🌲 Recent Hikes Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.recentHikes,
                  style: AppTextStyle.headlineMedium,
                ),
                if (controller.savedHikes.length > 5)
                  TextButton(
                    onPressed: controller.viewAllHikes,
                    child: Text(
                      'View All',
                      style: AppTextStyle.button.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),

            12.height,

            /// Hikes List
            _buildRecentHikesResult(),

            // Bottom spacing
            80.height,
          ],
        ),
      ),
    );
  }

  /// 👤 Header with Profile & Welcome Text
  Widget _buildProfileHeader() {
    return Row(
      children: [
        16.width,
        Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
              ), // Mock profile
              fit: BoxFit.cover,
            ),
          ),
        ),
        12.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.welcomeBack,
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Hiker John', // Mock Name
              style: AppTextStyle.headlineSmall,
            ),
          ],
        ),
      ],
    );
  }

  /// 🖼️ Image Slider with Dot Indicators
  Widget _buildImageSlider() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      height: 200.h,
      borderRadius: 24,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          PageView.builder(
            itemCount: controller.sliderImages.length,
            onPageChanged: controller.updateSliderIndex,
            itemBuilder: (context, index) {
              return CustomCachedImage(
                imageUrl: controller.sliderImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                borderRadius: 24,
              );
            },
          ),

          // Overlay Gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),

          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.readyToExplore,
                  style: AppTextStyle.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                8.height,
                // Custom Dot Indicator
                Obx(
                  () => Row(
                    children: List.generate(
                      controller.sliderImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: controller.sliderIndex.value == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: controller.sliderIndex.value == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 Stats Section (Circular/Grid layout)
  Widget _buildStatsSection() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      borderRadius: 24,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.place_outlined,
              controller.totalPlaces.value,
              AppStrings.totalPlaces,
            ),
            Container(width: 1, height: 40, color: AppColors.divider),
            _buildStatItem(
              Icons.straighten,
              controller.totalDistanceStat.value,
              AppStrings.distance,
            ),
            Container(width: 1, height: 40, color: AppColors.divider),
            _buildStatItem(
              Icons.timer_outlined,
              controller.totalTimeStat.value,
              AppStrings.totalTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        8.height,
        Text(value, style: AppTextStyle.headlineSmall.copyWith(fontSize: 16)),
        4.height,
        Text(
          label,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 🌲 Recent Hikes List (Reactive)
  Widget _buildRecentHikesResult() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.savedHikes.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Icon(
                  Icons.hiking,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                12.height,
                Text(
                  AppStrings.noHikesMessage,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Show top 5 recent hikes
      final displayHikes = controller.recentHikes;

      return Column(
        children: displayHikes.map((hike) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => controller.viewHikeDetails(hike),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                child: Row(
                  children: [
                    // Hike Thumb
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.landscape,
                          color: AppColors.textSecondary,
                        ),
                        // Or use image if available in Hike model
                      ),
                    ),
                    16.width,
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hike.name,
                            style: AppTextStyle.headlineSmall.copyWith(
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          6.height,
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              4.width,
                              Text(
                                Utils.formatDateTime(hike.startTime),
                                style: AppTextStyle.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Stats Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Utils.formatDistance(hike.totalDistance),
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        4.height,
                        Text(
                          Utils.formatDuration(hike.duration),
                          style: AppTextStyle.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
