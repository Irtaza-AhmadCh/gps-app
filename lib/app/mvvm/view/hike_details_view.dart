import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide WidgetPaddingX;
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../config/utils.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/map_widget.dart';
import '../view_model/hike_details_view_model.dart';

/// Hike Details View - Full review of completed hike
class HikeDetailsView extends GetView<HikeDetailsViewModel> {
  const HikeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final hike = controller.hike;

    if (hike == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header image with title overlay
          SliverAppBar(
            elevation: 0,
            shadowColor: Colors.transparent,
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,

            leading: GestureDetector(
              onTap: () => Get.back(),
              child: GlassContainer(
                width: 36.sp,
                height: 36.sp,
                borderRadius: 40.sp,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ).paddingOnly(left: 12, top: 8, bottom: 8),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16,
              ),
              title: Text(
                hike.name,
                style: AppTextStyle.headlineMedium.copyWith(
                  shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (hike.imageUrls != null && hike.imageUrls!.isNotEmpty)
                    Image.network(
                      hike.imageUrls!.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.landscape,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.landscape,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    ),

                  // Dark gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place
                  if (hike.place != null && hike.place!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hike.place!,
                          style: AppTextStyle.headlineSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Gallery Button (if images exist)
                  if (hike.imageUrls != null && hike.imageUrls!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Show gallery dialog or simple display
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              child: GlassContainer(
                                child: SizedBox(
                                  width: double.maxFinite,
                                  height: 400,
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                    itemCount: hike.imageUrls!.length,
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          hike.imageUrls![index],
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.photo_library,
                          color: AppColors.textPrimary,
                        ),
                        label: Text(
                          'View Gallery (${hike.imageUrls!.length})',
                          style: AppTextStyle.button,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.dimGrey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  if (hike.description != null &&
                      hike.description!.isNotEmpty) ...[
                    Text(
                      AppStrings.yourThoughts,
                      style: AppTextStyle.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hike.description!,
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Stats summary
                  Text(
                    AppStrings.hikeStats,
                    style: AppTextStyle.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildStatRow(
                          Icons.straighten,
                          AppStrings.distance,
                          Utils.formatDistance(hike.totalDistance),
                        ),
                        const Divider(color: AppColors.dimGrey, height: 24),
                        _buildStatRow(
                          Icons.timer,
                          AppStrings.duration,
                          Utils.formatDuration(hike.duration),
                        ),
                        const Divider(color: AppColors.dimGrey, height: 24),
                        _buildStatRow(
                          Icons.speed,
                          AppStrings.avgSpeed,
                          Utils.formatSpeed(hike.averageSpeed),
                        ),
                        const Divider(color: AppColors.dimGrey, height: 24),
                        _buildStatRow(
                          Icons.trending_up,
                          AppStrings.elevationGain,
                          Utils.formatElevationSimple(hike.elevationGain),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Route preview
                  Text(
                    AppStrings.routePreview,
                    style: AppTextStyle.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        child: MapWidget(
                          points: hike.points,
                          showStartMarker: true,
                          showCurrentMarker: false,
                          isInteractive: false,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tags
                  if (hike.tags != null && hike.tags!.isNotEmpty) ...[
                    Text(AppStrings.tags, style: AppTextStyle.headlineMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hike.tags!
                          .map(
                            (tag) => Chip(
                              label: Text(tag, style: AppTextStyle.bodySmall),
                              backgroundColor: AppColors.surface,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyle.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
