import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_routes.dart';
import '../../services/logger_service.dart';
import '../../repository/hike_repository.dart';
import '../../repository/offline_region_repository.dart';
import '../model/track_point.dart';
import '../../services/slope_service.dart';
import '../model/slope_segment.dart';

/// Controller for Live Tracking View
/// Manages real-time GPS tracking, statistics, and hike recording
class HikeTrackingController extends GetxController {
  final HikeRepository _repository = HikeRepository();
  final OfflineRegionRepository _offlineRepo = OfflineRegionRepository();

  // Observable state
  final RxList<TrackPoint> trackPoints = <TrackPoint>[].obs;
  final Rx<TrackPoint?> currentLocation = Rx<TrackPoint?>(null);
  final RxDouble totalDistance = 0.0.obs;
  final RxDouble elevationGain = 0.0.obs;
  final RxDouble elevationLoss = 0.0.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxBool isTracking = false.obs; // Means location service is active
  final RxBool isPaused = false.obs;
  final RxBool followUser = true.obs;

  // Map Layers & Slope Coloring
  final SlopeService _slopeService = SlopeService.instance;
  final RxList<SlopeSegment> slopeSegments = <SlopeSegment>[].obs;
  final RxBool showSlopeColoring = false.obs;

  // New state for manual start
  final RxBool isGpsReady = false.obs;
  final RxBool isHikeStarted = false.obs;

  final MapController mapController = MapController();

  StreamSubscription<TrackPoint>? _locationSubscription;
  Timer? _durationTimer;
  DateTime? _startTime;
  DateTime? _pauseTime;
  Duration _pausedDuration = Duration.zero;

  // Constants for filtering
  static const double _minAccuracy = 20.0; // Ignore points with >20m accuracy
  static const double _stationaryThreshold =
      2.0; // Movement less than 2m is stationary

  // Offline map download state
  final RxBool isDownloadMode = false.obs;
  final Rx<LatLng?> selectionStart = Rx<LatLng?>(null);
  final Rx<LatLng?> selectionEnd = Rx<LatLng?>(null);
  final RxInt estimatedTiles = 0.obs;
  final RxString estimatedSize = ''.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  static const int _minZoom = 10;
  static const int _maxZoom = 16;
  static const int _avgTileSizeBytes = 20000;
  static const int _maxStorageBytes = 500 * 1024 * 1024;

  @override
  void onInit() {
    super.onInit();
    _offlineRepo.init();
  }

  @override
  void onClose() {
    LoggerService.i(
      'HikeTrackingController.onClose: cancelling subscriptions and timers',
    );
    _locationSubscription?.cancel();
    _durationTimer?.cancel();
    mapController.dispose();
    super.onClose();
  }

  /// Initialize location services without starting hike recording
  Future<void> initializeLocationService() async {
    try {
      LoggerService.i(
        'HikeTrackingController.initializeLocationService: initializing...',
      );

      // Check permissions
      final hasPermission = await _repository.hasLocationPermission();
      if (!hasPermission) {
        final granted = await _repository.requestLocationPermission();
        if (!granted) {
          Get.snackbar(
            'Permission Required',
            'Location permission is required to track hikes',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Check location services
      final serviceEnabled = await _repository.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS Disabled',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Start listening to location updates immediately for the map
      isTracking.value = true;
      _locationSubscription = _repository.startTracking().listen(
        _onLocationUpdate,
        onError: (error) {
          LoggerService.e('HikeTrackingController: Tracking error: $error');
          Get.snackbar(
            'Tracking Error',
            'GPS tracking failed: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
          stopTracking(saveHike: false);
        },
      );
    } catch (e, stackTrace) {
      LoggerService.e(
        'HikeTrackingController.initializeLocationService: Failed to init: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Manually start hike recording
  void startHikeRecording() {
    if (!isGpsReady.value) {
      Get.snackbar(
        'GPS Not Ready',
        'Waiting for better GPS signal...',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    LoggerService.i('HikeTrackingController.startHikeRecording: Starting hike');

    // Reset state
    trackPoints.clear();
    totalDistance.value = 0.0;
    elevationGain.value = 0.0;
    elevationLoss.value = 0.0;
    duration.value = Duration.zero;
    _pausedDuration = Duration.zero;
    _startTime = DateTime.now();

    // Set recording flags
    isHikeStarted.value = true;
    isPaused.value = false;

    // Start duration timer
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused.value && isHikeStarted.value) {
        duration.value =
            DateTime.now().difference(_startTime!) - _pausedDuration;
      }
    });
  }

  /// Handle location updates
  void _onLocationUpdate(TrackPoint point) {
    // Basic validity check
    if (point.latitude == 0 && point.longitude == 0) return;

    // Update current location immediately for the map UI (blue dot)
    // This happens even before hike starts, so user can see where they are
    currentLocation.value = point;
    isGpsReady.value = true;

    // If hike hasn't started manually, we don't record anything else
    if (!isHikeStarted.value) {
      // Still auto-center map if following
      if (followUser.value) {
        _moveMap(point);
      }
      return;
    }

    // --- Recording Logic Below ---

    // 1. Accuracy Filtering
    // If accuracy is too poor, ignore the point to prevent drift
    if (point.accuracy != null && point.accuracy! > _minAccuracy) {
      LoggerService.i(
        'HikeTrackingController._onLocationUpdate: Filtering out low accuracy point: ${point.accuracy}m',
      );
      return;
    }

    // 2. Stationary Drift Filtering
    if (trackPoints.isNotEmpty) {
      final lastPoint = trackPoints.last;
      final distance = _repository.calculateTotalDistance([lastPoint, point]);

      // If movement is very small and accuracy is not perfect, ignore to prevent "jumping"
      if (distance < _stationaryThreshold && (point.accuracy ?? 0) > 5.0) {
        return;
      }
    }

    LoggerService.i(
      'HikeTrackingController._onLocationUpdate: New location update: ${point.latitude}, ${point.longitude}, alt: ${point.altitude}, acc: ${point.accuracy}',
    );
    trackPoints.add(point);

    // 3. Map Auto-centering
    if (followUser.value) {
      _moveMap(point);
    }

    // Update statistics
    _updateStatistics();
  }

  void _moveMap(TrackPoint point) {
    try {
      mapController.move(
        LatLng(point.latitude, point.longitude),
        mapController.camera.zoom,
      );
    } catch (e) {
      // Map might not be ready or app is in background, ignore UI update errors
    }
  }

  /// Update statistics from track points
  void _updateStatistics() {
    if (trackPoints.length < 2) return;

    // Calculate total distance
    totalDistance.value = _repository.calculateTotalDistance(trackPoints);

    // Calculate elevation changes
    final elevationChange = _repository.calculateElevationChange(trackPoints);
    elevationGain.value = elevationChange.gain;
    elevationLoss.value = elevationChange.loss;

    if (showSlopeColoring.value) {
      slopeSegments.value = _slopeService.generateSlopeSegments(trackPoints);
    }

    LoggerService.i(
      'HikeTrackingController._updateStatistics: Updated statistics - Distance: ${totalDistance.value}m, Gain: ${elevationGain.value}m, Loss: ${elevationLoss.value}m',
    );
  }

  /// Pause tracking
  void pauseTracking() {
    if (!isTracking.value || isPaused.value) return;

    isPaused.value = true;
    _pauseTime = DateTime.now();
    _locationSubscription?.pause();
    LoggerService.i(
      'HikeTrackingController.pauseTracking: Tracking paused at $_pauseTime',
    );
  }

  /// Resume tracking
  void resumeTracking() {
    if (!isTracking.value || !isPaused.value) return;

    isPaused.value = false;
    if (_pauseTime != null) {
      _pausedDuration += DateTime.now().difference(_pauseTime!);
    }
    _locationSubscription?.resume();
    LoggerService.i(
      'HikeTrackingController.resumeTracking: Tracking resumed, total paused duration: $_pausedDuration',
    );
  }

  /// Stop tracking and navigate to details view
  Future<void> stopTracking({bool saveHike = true}) async {
    LoggerService.i(
      'HikeTrackingController.stopTracking: Stopping tracking, saveHike: $saveHike',
    );
    _locationSubscription?.cancel();
    _durationTimer?.cancel();

    isTracking.value = false;
    isHikeStarted.value = false;
    isPaused.value = false;

    if (saveHike && trackPoints.isNotEmpty) {
      if (_startTime == null) {
        LoggerService.e('HikeTrackingController: Start time is null');
        Get.back();
        return;
      }

      // Create temporary Hike object
      final hike = _repository.createHikeObject(
        name: 'Hike ${DateTime.now().day}/${DateTime.now().month}',
        points: List.from(trackPoints),
        startTime: _startTime!,
        endTime: DateTime.now(),
      );

      // Navigate to Add Details View with the hike object
      // Using offNamed so user can't go back to tracking state easily without restarting
      Get.offNamed(AppRoutes.addHikeDetails, arguments: hike);
    } else {
      Get.back(); // Return to home
      LoggerService.i(
        'HikeTrackingController.stopTracking: Tracking stopped without saving hike',
      );
    }
  }

  // _showSaveDialog and _saveHike are no longer needed here as logic moved to AddHikeDetailsViewModel

  // ── Offline Map Download Logic ──

  void startDownloadMode() {
    isDownloadMode.value = true;
    selectionStart.value = null;
    selectionEnd.value = null;
    estimatedTiles.value = 0;
    estimatedSize.value = '';

    // Auto-pause tracking logic if we want, but instruction says "Tracking continues in background",
    // so we just let it continue but we allow map to be interacted with decoupled from centering
    followUser.value = false;
  }

  void cancelDownloadMode() {
    isDownloadMode.value = false;
    selectionStart.value = null;
    selectionEnd.value = null;
    estimatedTiles.value = 0;
    estimatedSize.value = '';
    followUser.value = true;
  }

  void onMapTap(LatLng point) {
    if (!isDownloadMode.value) return;

    if (selectionStart.value == null) {
      selectionStart.value = point;
    } else if (selectionEnd.value == null) {
      selectionEnd.value = point;
      _estimateDownload();
    } else {
      selectionStart.value = point;
      selectionEnd.value = null;
      estimatedTiles.value = 0;
      estimatedSize.value = '';
    }
  }

  void _estimateDownload() {
    if (selectionStart.value == null || selectionEnd.value == null) return;

    final bounds = _getSelectionBounds();
    final tiles = _offlineRepo.estimateTileCount(
      minLat: bounds.minLat,
      maxLat: bounds.maxLat,
      minLng: bounds.minLng,
      maxLng: bounds.maxLng,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
    );

    estimatedTiles.value = tiles;
    estimatedSize.value = _formatBytes(tiles * _avgTileSizeBytes);
  }

  Future<void> downloadRegion(
    String regionName, {
    int zoomLevel = _maxZoom,
  }) async {
    if (selectionStart.value == null || selectionEnd.value == null) return;

    final currentUsage = _offlineRepo.getTotalStorageUsed();
    final estimatedBytes = estimatedTiles.value * _avgTileSizeBytes;
    if (currentUsage + estimatedBytes > _maxStorageBytes) {
      Get.snackbar(
        'Storage Limit',
        'This download would exceed the 500MB storage limit.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      final bounds = _getSelectionBounds();

      await _offlineRepo.saveRegion(
        name: regionName,
        minLat: bounds.minLat,
        maxLat: bounds.maxLat,
        minLng: bounds.minLng,
        maxLng: bounds.maxLng,
        minZoom: _minZoom,
        maxZoom: zoomLevel,
        tileCount: estimatedTiles.value,
        sizeBytes: estimatedBytes,
      );

      // Simulate download progress since we can't easily hook into FMTC stream here
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        downloadProgress.value = i / 100;
      }

      Get.snackbar(
        'Download Complete',
        'Region "$regionName" saved for offline use',
        snackPosition: SnackPosition.BOTTOM,
      );

      cancelDownloadMode();
    } catch (e) {
      LoggerService.e('HikeTrackingController.downloadRegion: failed: $e');
      Get.snackbar(
        'Download Failed',
        'Failed to download region',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool get hasCompleteSelection =>
      selectionStart.value != null && selectionEnd.value != null;

  List<LatLng> getPolygonPoints() {
    if (selectionStart.value == null || selectionEnd.value == null) return [];
    final a = selectionStart.value!;
    final b = selectionEnd.value!;
    return [
      LatLng(a.latitude, a.longitude),
      LatLng(a.latitude, b.longitude),
      LatLng(b.latitude, b.longitude),
      LatLng(b.latitude, a.longitude),
    ];
  }

  void toggleSlopeColoring() {
    showSlopeColoring.value = !showSlopeColoring.value;
    if (showSlopeColoring.value) {
      slopeSegments.value = _slopeService.generateSlopeSegments(trackPoints);
    }
  }
}
