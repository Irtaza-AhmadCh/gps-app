import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../config/utils.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/place_item_widget.dart';
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
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hike.name,
                style: AppTextStyle.headlineMedium.copyWith(
                  shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Obx(() {
                    final images = controller.images;
                    if (images.isNotEmpty) {
                      return Image.network(
                        images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.landscape,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.landscape,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    );
                  }),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Places visited
                  Text(
                    AppStrings.placesVisited,
                    style: AppTextStyle.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final places = controller.places;
                    if (places.isEmpty) {
                      return GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            AppStrings.noPlacesAdded,
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: places.map((place) {
                        return PlaceItemWidget(
                          name: place.name,
                          description: place.description,
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 32),
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
