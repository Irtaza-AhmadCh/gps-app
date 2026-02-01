import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:gps/app/config/utils.dart';
import 'package:gps/app/widgets/glass_container.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_colors.dart';
import '../services/map_tile_service.dart';
import '../mvvm/model/track_point.dart';

/// Reusable map widget with OpenStreetMap
/// Displays route polyline, markers, and handles offline behavior
class MapWidget extends StatelessWidget {
  final List<TrackPoint> points;
  final TrackPoint? currentPoint;
  final bool showStartMarker;
  final bool showCurrentMarker;
  final LatLng? center;
  final double zoom;
  final MapController? mapController;

  const MapWidget({
    super.key,
    required this.points,
    this.currentPoint,
    this.showStartMarker = true,
    this.showCurrentMarker = true,
    this.center,
    this.zoom = 15.0,
    this.mapController,
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

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: zoom,
            minZoom: 1,
            maxZoom: 19,
          ),
          children: [
            // Tile layer with offline support
            tileService.getTileLayer(),

            // Route polyline
            if (polylinePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    color: AppColors.routePolyline,
                    strokeWidth: 4.0,
                  ),
                ],
              ),

            // Markers
            if (markers.isNotEmpty) MarkerLayer(markers: markers),
          ],
        ),

        const MapSkinSwitcher(),

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

        // Offline placeholder (shown when no points and potentially offline)
        // if ()
        //   Center(
        //     child: Container(
        //       padding: const EdgeInsets.all(24),
        //       decoration: BoxDecoration(
        //         color: AppColors.mapPlaceholder,
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Icon(
        //             Icons.map_outlined,
        //             size: 48,
        //             color: AppColors.mapPlaceholderText,
        //           ),
        //           const SizedBox(height: 12),
        //           Text(
        //             '
        //ting for GPS signal...',
        //             style: TextStyle(
        //               color: AppColors.mapPlaceholderText,
        //               fontSize: 14,
        //             ),
        //             textAlign: TextAlign.center,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}

/// Floating widget to switch between map skins dynamically
class MapSkinSwitcher extends StatelessWidget {
  const MapSkinSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    // Get list of registered skins
    final skins = MapTileService.instance.skinlist;

    return Positioned(
      top: 16,
      right: 16,
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        blur: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Map Style',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            8.height, // Using your extensions for spacing
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(skins.length, (index) {
                final skin = skins[index];
                return Obx(
                  () => GestureDetector(
                    onTap: () {
                      MapTileService.instance.changeSkin(skin.name);
                    },
                    child: Container(
                      width: 50,
                      height: 30,
                      margin: const EdgeInsets.symmetric(vertical: 4),

                      decoration: BoxDecoration(
                        color:
                            MapTileService.instance.currentSkinNameRx.value ==
                                skin.name
                            ? AppColors.primary.withOpacity(0.8)
                            : AppColors.dimGrey.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          skin.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
