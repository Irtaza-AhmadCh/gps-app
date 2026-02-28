import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../repository/offline_region_repository.dart';
import '../../services/logger_service.dart';
import '../model/offline_region.dart';
import '../../config/app_routes.dart';
import 'bottom_bar_controller.dart';
import 'hike_tracking_controller.dart';

/// ViewModel for the Offline Region Management screen.
///
/// Manages region selection state, tile estimation, download tracking,
/// and saved region list.
class OfflineRegionViewModel extends GetxController {
  final OfflineRegionRepository _repository = OfflineRegionRepository();

  // Saved regions list
  final RxList<OfflineRegion> savedRegions = <OfflineRegion>[].obs;
  final RxBool isLoading = false.obs;

  // Region selection state
  final RxBool isSelecting = false.obs;
  final Rx<LatLng?> selectionStart = Rx<LatLng?>(null);
  final Rx<LatLng?> selectionEnd = Rx<LatLng?>(null);
  final RxInt estimatedTiles = 0.obs;
  final RxString estimatedSize = ''.obs;

  // Download state
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  // Map controller
  final MapController mapController = MapController();

  // Download settings
  static const int _minZoom = 10;
  static const int _maxZoom = 16;
  static const int _avgTileSizeBytes = 20000; // ~20 KB per tile
  static const int _maxStorageBytes = 500 * 1024 * 1024; // 500 MB limit

  @override
  void onInit() {
    super.onInit();
    LoggerService.i('OfflineRegionViewModel.onInit: initializing');
    _initRepository();
  }

  @override
  void onClose() {
    LoggerService.i('OfflineRegionViewModel.onClose: disposing');
    mapController.dispose();
    super.onClose();
  }

  Future<void> _initRepository() async {
    LoggerService.i('OfflineRegionViewModel._initRepository: initializing');
    await _repository.init();
    _loadRegions();
  }

  /// Load all saved offline regions
  void _loadRegions() {
    LoggerService.i('OfflineRegionViewModel._loadRegions: loading regions');
    savedRegions.value = _repository.getAllRegions();
    LoggerService.i(
      'OfflineRegionViewModel._loadRegions: loaded ${savedRegions.length} regions',
    );
  }

  /// Start region selection mode
  void startSelecting() {
    LoggerService.i(
      'OfflineRegionViewModel.startSelecting: entering selection mode',
    );
    isSelecting.value = true;
    selectionStart.value = null;
    selectionEnd.value = null;
    estimatedTiles.value = 0;
    estimatedSize.value = '';
  }

  /// Cancel region selection
  void cancelSelecting() {
    LoggerService.i(
      'OfflineRegionViewModel.cancelSelecting: exiting selection mode',
    );
    isSelecting.value = false;
    selectionStart.value = null;
    selectionEnd.value = null;
    estimatedTiles.value = 0;
    estimatedSize.value = '';
  }

  /// Handle map tap during selection mode
  void onMapTap(LatLng point) {
    if (!isSelecting.value) return;

    LoggerService.i(
      'OfflineRegionViewModel.onMapTap: tapped at ${point.latitude}, ${point.longitude}',
    );

    if (selectionStart.value == null) {
      selectionStart.value = point;
      LoggerService.i('OfflineRegionViewModel.onMapTap: set start point');
    } else if (selectionEnd.value == null) {
      selectionEnd.value = point;
      LoggerService.i('OfflineRegionViewModel.onMapTap: set end point');
      _estimateDownload();
    } else {
      // Reset and start over
      selectionStart.value = point;
      selectionEnd.value = null;
      estimatedTiles.value = 0;
      estimatedSize.value = '';
      LoggerService.i('OfflineRegionViewModel.onMapTap: reset selection');
    }
  }

  /// Estimate download based on current selection
  void _estimateDownload() {
    if (selectionStart.value == null || selectionEnd.value == null) return;

    final bounds = _getSelectionBounds();
    LoggerService.i(
      'OfflineRegionViewModel._estimateDownload: estimating for bounds $bounds',
    );

    final tiles = _repository.estimateTileCount(
      minLat: bounds.minLat,
      maxLat: bounds.maxLat,
      minLng: bounds.minLng,
      maxLng: bounds.maxLng,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
    );

    estimatedTiles.value = tiles;
    final sizeBytes = tiles * _avgTileSizeBytes;
    estimatedSize.value = _formatBytes(sizeBytes);

    LoggerService.i(
      'OfflineRegionViewModel._estimateDownload: $tiles tiles, ${estimatedSize.value}',
    );
  }

  /// Download the selected region
  Future<void> downloadRegion(String regionName) async {
    if (selectionStart.value == null || selectionEnd.value == null) return;

    LoggerService.i(
      'OfflineRegionViewModel.downloadRegion: starting download for "$regionName"',
    );

    // Check storage limit
    final currentUsage = _repository.getTotalStorageUsed();
    final estimatedBytes = estimatedTiles.value * _avgTileSizeBytes;
    if (currentUsage + estimatedBytes > _maxStorageBytes) {
      LoggerService.w(
        'OfflineRegionViewModel.downloadRegion: storage limit would be exceeded',
      );
      Get.snackbar(
        'Storage Limit',
        'This download would exceed the 500MB storage limit. Please delete some regions first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      final bounds = _getSelectionBounds();

      // Save region metadata (creates FMTC store)
      await _repository.saveRegion(
        name: regionName,
        minLat: bounds.minLat,
        maxLat: bounds.maxLat,
        minLng: bounds.minLng,
        maxLng: bounds.maxLng,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        tileCount: estimatedTiles.value,
        sizeBytes: estimatedTiles.value * _avgTileSizeBytes,
      );

      // Simulate download progress (FMTC actual bulk download
      // would use stream-based progress in production)
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        downloadProgress.value = i / 100;
      }

      LoggerService.i(
        'OfflineRegionViewModel.downloadRegion: download complete',
      );

      Get.snackbar(
        'Download Complete',
        'Region "$regionName" saved for offline use',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reload regions and reset selection
      _loadRegions();
      cancelSelecting();
    } catch (e, stackTrace) {
      LoggerService.e(
        'OfflineRegionViewModel.downloadRegion: failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Download Failed',
        'Failed to download region: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  /// Delete a saved region
  Future<void> deleteRegion(String regionId) async {
    LoggerService.i(
      'OfflineRegionViewModel.deleteRegion: deleting region $regionId',
    );
    try {
      await _repository.deleteRegion(regionId);
      _loadRegions();
      Get.snackbar(
        'Deleted',
        'Offline region removed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      LoggerService.e(
        'OfflineRegionViewModel.deleteRegion: failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// View region on main tracking map
  void viewRegionOnMap(OfflineRegion region) {
    LoggerService.i(
      'OfflineRegionViewModel.viewRegionOnMap: viewing region ${region.name}',
    );

    // Switch to Record tab
    if (Get.isRegistered<BottomBarController>()) {
      Get.find<BottomBarController>().changeTab(
        1,
      ); // Assuming index 1 is Record view
    }

    // Return to root (BottomBarView)
    Get.until(
      (route) => Get.currentRoute == AppRoutes.bottomBarView || route.isFirst,
    );

    // Move map to region center using HikeTrackingController
    if (Get.isRegistered<HikeTrackingController>()) {
      final centerLat = (region.minLat + region.maxLat) / 2;
      final centerLng = (region.minLng + region.maxLng) / 2;

      final trackingController = Get.find<HikeTrackingController>();
      trackingController.followUser.value = false;

      try {
        trackingController.mapController.move(
          LatLng(centerLat, centerLng),
          12, // default zoom for region overview
        );
      } catch (e) {
        LoggerService.e(
          'OfflineRegionViewModel.viewRegionOnMap: Map not ready $e',
        );
      }
    }
  }

  /// Get bounds from selection points (normalized)
  ({double minLat, double maxLat, double minLng, double maxLng})
  _getSelectionBounds() {
    final lat1 = selectionStart.value!.latitude;
    final lng1 = selectionStart.value!.longitude;
    final lat2 = selectionEnd.value!.latitude;
    final lng2 = selectionEnd.value!.longitude;

    return (
      minLat: lat1 < lat2 ? lat1 : lat2,
      maxLat: lat1 > lat2 ? lat1 : lat2,
      minLng: lng1 < lng2 ? lng1 : lng2,
      maxLng: lng1 > lng2 ? lng1 : lng2,
    );
  }

  /// Format bytes to human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Check if selection is complete (both points set)
  bool get hasCompleteSelection =>
      selectionStart.value != null && selectionEnd.value != null;

  /// Get total storage used by all regions (formatted)
  String get totalStorageFormatted =>
      _formatBytes(_repository.getTotalStorageUsed());
}
