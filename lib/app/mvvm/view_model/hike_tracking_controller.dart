import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../services/logger_service.dart';
import '../../repository/hike_repository.dart';
import '../model/track_point.dart';

/// Controller for Live Tracking View
/// Manages real-time GPS tracking, statistics, and hike recording
class HikeTrackingController extends GetxController {
  final HikeRepository _repository = HikeRepository();

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

  /// Stop tracking and optionally save hike
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
      await _showSaveDialog();
    } else {
      Get.back(); // Return to home
      LoggerService.i(
        'HikeTrackingController.stopTracking: Tracking stopped without saving hike',
      );
    }
  }

  /// Show dialog to save hike
  Future<void> _showSaveDialog() async {
    LoggerService.i(
      'HikeTrackingController._showSaveDialog: Showing save hike dialog',
    );
    final TextEditingController nameController = TextEditingController(
      text: 'Hike ${DateTime.now().day}/${DateTime.now().month}',
    );

    await Get.dialog(
      AlertDialog(
        title: const Text('Save Hike'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Hike Name',
            hintText: 'Enter a name for this hike',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Return to home without saving
              LoggerService.i(
                'HikeTrackingController._showSaveDialog: User discarded hike',
              );
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'Invalid Name',
                  'Please enter a hike name',
                  snackPosition: SnackPosition.BOTTOM,
                );
                LoggerService.i(
                  'HikeTrackingController._showSaveDialog: Invalid hike name entered',
                );
                return;
              }

              Get.back(); // Close dialog
              await _saveHike(name);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Save hike to storage
  Future<void> _saveHike(String name) async {
    try {
      LoggerService.i('HikeTrackingController._saveHike: Saving hike: $name');
      final hike = await _repository.createHike(
        name: name,
        points: trackPoints,
        startTime: _startTime!,
        endTime: DateTime.now(),
      );

      Get.snackbar(
        'Success',
        'Hike saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      LoggerService.i(
        'HikeTrackingController._saveHike: Hike saved successfully, navigating to summary',
      );
      // Navigate to summary
      Get.offNamed('/summary', arguments: hike);
    } catch (e, stackTrace) {
      LoggerService.e(
        'HikeTrackingController._saveHike: Failed to save hike: $e',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to save hike: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back(); // Return to home
    }
  }
}
