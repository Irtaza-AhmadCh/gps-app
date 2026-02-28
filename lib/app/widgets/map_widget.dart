import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:gps/app/config/app_text_style.dart';
import 'package:gps/app/config/utils.dart';
import 'package:gps/app/widgets/glass_container.dart';
import 'package:gps/app/widgets/slope_legend_widget.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_colors.dart';
import '../services/map_tile_service.dart';
import '../mvvm/model/track_point.dart';
import '../mvvm/model/slope_segment.dart';

/// Reusable map widget with OpenStreetMap
/// Displays route polyline, markers, and handles offline behavior
/// Supports optional slope-colored polylines via [slopeSegments]
class MapWidget extends StatelessWidget {
  final List<TrackPoint> points;
  final TrackPoint? currentPoint;
  final bool showStartMarker;
  final bool showCurrentMarker;
  final LatLng? center;
  final double zoom;
  final MapController? mapController;
  final bool isInteractive;
  final bool? showMapSkinSwitcher;
  final void Function(TapPosition, LatLng)? onTap;
  final List<Widget>? extraLayers;

  /// Optional slope segments for gradient-colored polylines
  final List<SlopeSegment>? slopeSegments;

  /// Whether to show slope coloring (when slopeSegments is provided)
  final bool showSlopeColoring;

  /// Whether to show the slope legend overlay
  final bool showSlopeLegend;

  /// Callback when slope coloring is toggled from the layers menu
  final ValueChanged<bool>? onSlopeToggle;

  const MapWidget({
    super.key,
    required this.points,
    this.currentPoint,
    this.showStartMarker = true,
    this.showCurrentMarker = true,
    this.center,
    this.zoom = 15.0,
    this.mapController,
    this.isInteractive = true,
    this.showMapSkinSwitcher,
    this.slopeSegments,
    this.showSlopeColoring = false,
    this.showSlopeLegend = false,
    this.onSlopeToggle,
    this.onTap,
    this.extraLayers,
  });

  @override
  Widget build(BuildContext context) {
    final MapTileService tileService = MapTileService.instance;

    // Determine map center
    LatLng mapCenter;
    if (center != null) {
      mapCenter = center!;
    } else if (currentPoint != null) {
      mapCenter = LatLng(currentPoint!.latitude, currentPoint!.longitude);
    } else if (points.isNotEmpty) {
      mapCenter = LatLng(points.first.latitude, points.first.longitude);
    } else {
      mapCenter = LatLng(0, 0); // Default fallback
    }

    // Build polyline from points
    final List<LatLng> polylinePoints = points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Build markers
    final List<Marker> markers = [];

    // Start marker (green)
    if (showStartMarker && points.isNotEmpty) {
      markers.add(
        Marker(
          point: LatLng(points.first.latitude, points.first.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.flag, color: AppColors.startMarker, size: 40),
        ),
      );
    }

    // Current position marker (blue)
    if (showCurrentMarker && currentPoint != null) {
      markers.add(
        Marker(
          point: LatLng(currentPoint!.latitude, currentPoint!.longitude),
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: Colors.blue, size: 40),
        ),
      );
    }

    // Build polyline layers (slope-colored or standard)
    final List<Polyline> polylines = _buildPolylines(polylinePoints);

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: zoom,
            minZoom: 1,
            maxZoom: 19,
            onTap: onTap,
            interactionOptions: InteractionOptions(
              flags: isInteractive ? InteractiveFlag.all : InteractiveFlag.none,
            ),
          ),
          children: [
            // Tile layer with offline support
            tileService.getTileLayer(),

            // Route polyline(s) — slope-colored or standard
            if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),

            // Markers
            if (markers.isNotEmpty) MarkerLayer(markers: markers),

            if (extraLayers != null) ...extraLayers!,
          ],
        ),

        if (showMapSkinSwitcher ?? true)
          MapSkinSwitcher(
            showSlopeColoring: showSlopeColoring,
            onSlopeToggle: onSlopeToggle,
          ),

        // Slope legend overlay
        if (showSlopeLegend && showSlopeColoring && slopeSegments != null)
          Positioned(bottom: 40, left: 8, child: const SlopeLegendWidget()),

        // Attribution
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tileService.getAttributionText(),
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  /// Build polylines for the map — either slope-colored segments or a single standard polyline
  List<Polyline> _buildPolylines(List<LatLng> polylinePoints) {
    if (polylinePoints.isEmpty) return [];

    // If slope coloring is enabled and segments are available, render colored polylines
    if (showSlopeColoring &&
        slopeSegments != null &&
        slopeSegments!.isNotEmpty) {
      final List<Polyline> coloredPolylines = [];

      for (final segment in slopeSegments!) {
        // Guard against out-of-bounds indices
        final start = segment.startIndex.clamp(0, polylinePoints.length - 1);
        final end = (segment.endIndex + 1).clamp(
          start + 1,
          polylinePoints.length,
        );

        if (end - start < 2) continue;

        coloredPolylines.add(
          Polyline(
            points: polylinePoints.sublist(start, end),
            color: segment.difficulty.color,
            strokeWidth: 5.0,
          ),
        );
      }

      return coloredPolylines;
    }

    // Default: single color polyline
    return [
      Polyline(
        points: polylinePoints,
        color: AppColors.routePolyline,
        strokeWidth: 4.0,
      ),
    ];
  }
}

class MapSkinSwitcher extends StatelessWidget {
  final bool showSlopeColoring;
  final ValueChanged<bool>? onSlopeToggle;

  const MapSkinSwitcher({
    super.key,
    this.showSlopeColoring = false,
    this.onSlopeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: _openBottomSheet,
        child: GlassContainer(
          padding: EdgeInsets.all(10.sp),
          borderRadius: 12.sp,
          blur: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.layers_outlined,
                color: AppColors.white,
                size: 18,
              ),
              6.width,
              Text(
                'Map',
                style: AppTextStyle.bodySmall.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBottomSheet() {
    final skins = MapTileService.instance.skinlist;

    Get.bottomSheet(
      GlassContainer(
        borderRadius: 24,
        blur: 12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            12.height,
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            16.height,
            ...skins.map(
              (skin) => Obx(
                () => GestureDetector(
                  onTap: () {
                    MapTileService.instance.changeSkin(skin.name);
                    Get.back();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.sp),
                    margin: EdgeInsets.symmetric(
                      horizontal: 6.sp,
                      vertical: 6.sp,
                    ),
                    decoration: BoxDecoration(
                      color:
                          MapTileService.instance.currentSkinNameRx.value ==
                              skin.name
                          ? AppColors.primary.withOpacity(0.85)
                          : AppColors.dimGrey.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      skin.name,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (onSlopeToggle != null) ...[
              const Divider(color: AppColors.dimGrey, height: 32),
              SwitchListTile(
                  title: Text(
                    'Slope Coloring',
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  subtitle: Text(
                    'Visualize steepness of the trail',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.platinum,
                    ),
                  ),
                  value: showSlopeColoring,
                  onChanged: (val) {
                    onSlopeToggle!(val);
                    Get.back();
                  },
                  activeColor: AppColors.primary,
                ),

            ],

            20.height,
          ],
        ),
      ),
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
    );
  }
}
