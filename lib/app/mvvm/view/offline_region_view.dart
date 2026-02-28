import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../config/app_text_style.dart';
import '../../config/utils.dart';
import '../../services/map_tile_service.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/region_selection_overlay.dart';
import '../view_model/offline_region_view_model.dart';

/// Offline Region Management View.
///
/// Allows users to:
/// - Select a map region by tapping two corners
/// - See estimated tile count and download size
/// - Download the selected region for offline use
/// - View and delete saved offline regions
class OfflineRegionView extends StatelessWidget {
  const OfflineRegionView({super.key});

  @override
  Widget build(BuildContext context) {
    final OfflineRegionViewModel controller =
        Get.find<OfflineRegionViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          AppStrings.offlineRegions,
          style: AppTextStyle.bodyMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          // Map with region selection
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Obx(() {
                  return FlutterMap(
                    mapController: controller.mapController,
                    options: MapOptions(
                      initialCenter: LatLng(33.6844, 73.0479), // Default center
                      initialZoom: 12,
                      onTap: (tapPosition, point) {
                        controller.onMapTap(point);
                      },
                    ),
                    children: [
                      MapTileService.instance.getTileLayer(),

                      // Draw selection rectangle as a polygon
                      if (controller.selectionStart.value != null &&
                          controller.selectionEnd.value != null)
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: _getPolygonPoints(
                                controller.selectionStart.value!,
                                controller.selectionEnd.value!,
                              ),
                              color: AppColors.primary.withOpacity(0.15),
                              borderColor: AppColors.primary,
                              borderStrokeWidth: 2,
                              isFilled: true,
                            ),
                          ],
                        ),

                      // Start marker
                      if (controller.selectionStart.value != null)
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
                  );
                }),

                // Selection instructions overlay
                Obx(() {
                  if (!controller.isSelecting.value) {
                    return const SizedBox.shrink();
                  }
                  String hint;
                  if (controller.selectionStart.value == null) {
                    hint = 'Tap to set first corner';
                  } else if (controller.selectionEnd.value == null) {
                    hint = 'Tap to set second corner';
                  } else {
                    hint = 'Region selected — ready to download';
                  }
                  return Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: GlassContainer(
                      padding: EdgeInsets.all(10.sp),
                      borderRadius: 10.sp,
                      blur: 10,
                      child: Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  );
                }),

                // Download progress overlay
                Obx(() {
                  if (!controller.isDownloading.value) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: GlassContainer(
                        padding: EdgeInsets.all(24.sp),
                        borderRadius: 16.sp,
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
                              AppStrings.downloading,
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
              ],
            ),
          ),

          // Bottom panel
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp),
                ),
              ),
              child: Obx(() {
                if (controller.isSelecting.value) {
                  return _buildSelectionPanel(controller);
                }
                return _buildRegionsPanel(controller);
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Panel shown during region selection
  Widget _buildSelectionPanel(OfflineRegionViewModel controller) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectRegion,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          12.height,

          // Estimation info
          Obx(() {
            if (controller.estimatedTiles.value > 0) {
              return GlassContainer(
                padding: EdgeInsets.all(12.sp),
                borderRadius: 10.sp,
                blur: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${controller.estimatedTiles.value}',
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppStrings.tileCount,
                          style: AppTextStyle.bodySmall.copyWith(
                            color: AppColors.platinum,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          controller.estimatedSize.value,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppStrings.estimatedSize,
                          style: AppTextStyle.bodySmall.copyWith(
                            color: AppColors.platinum,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const Spacer(),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  onTap: () => controller.cancelSelecting(),
                  label: AppStrings.cancel.tr,
                ),
              ),
              12.width,
              Expanded(
                child: Obx(
                  () => GlassButton(
                    onTap: () {
                      if (controller.hasCompleteSelection) {
                        _showNameDialog(controller);
                      }
                    },
                    label: AppStrings.downloadRegion,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Panel showing saved regions list
  Widget _buildRegionsPanel(OfflineRegionViewModel controller) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.manageRegions,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => Text(
                  controller.totalStorageFormatted,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.platinum,
                  ),
                ),
              ),
            ],
          ),
          12.height,

          // Regions list
          Expanded(
            child: Obx(() {
              if (controller.savedRegions.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noOfflineRegions,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.dimGrey,
                    ),
                  ),
                );
              }
              return ListView.separated(
                itemCount: controller.savedRegions.length,
                separatorBuilder: (_, __) => 8.height,
                itemBuilder: (context, index) {
                  final region = controller.savedRegions[index];
                  return GlassContainer(
                    padding: EdgeInsets.all(12.sp),
                    borderRadius: 10.sp,
                    blur: 8,
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                        12.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                region.name,
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              4.height,
                              Text(
                                '${region.tileCount} tiles • ${region.formattedSize}',
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: AppColors.platinum,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  controller.viewRegionOnMap(region),
                              icon: Icon(
                                Icons.visibility_outlined,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  controller.deleteRegion(region.id),
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          12.height,

          // Add region button
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onTap: () => controller.startSelecting(),
              label: AppStrings.downloadRegion.tr,
            ),
          ),
        ],
      ),
    );
  }

  /// Get polygon points from two corner coordinates
  List<LatLng> _getPolygonPoints(LatLng a, LatLng b) {
    return [
      LatLng(a.latitude, a.longitude),
      LatLng(a.latitude, b.longitude),
      LatLng(b.latitude, b.longitude),
      LatLng(b.latitude, a.longitude),
    ];
  }

  /// Show name input dialog before downloading
  void _showNameDialog(OfflineRegionViewModel controller) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          AppStrings.downloadRegion,
          style: AppTextStyle.bodyMedium.copyWith(color: AppColors.white),
        ),
        content: TextField(
          controller: textController,
          style: TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Region name',
            hintStyle: TextStyle(color: AppColors.dimGrey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.dimGrey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.platinum),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                Get.back();
                controller.downloadRegion(name);
              }
            },
            child: Text(
              AppStrings.downloadRegion,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
