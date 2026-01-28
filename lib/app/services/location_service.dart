import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'logger_service.dart';

/// Service for GPS location tracking
/// Handles permissions and provides real-time location stream
/// Works offline (GPS doesn't require internet)
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Check if location permission is granted
  Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    LoggerService.i(
      'LocationService.requestPermission: requesting location permission',
    );
    final status = await Permission.location.request();
    LoggerService.i(
      'LocationService.requestPermission: request result status: $status',
    );
    return status.isGranted;
  }

  /// Check if location permission is permanently denied
  Future<bool> isPermissionDeniedForever() async {
    final status = await Permission.location.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings for manual permission grant
  Future<void> openSettings() async {
    LoggerService.i('LocationService.openSettings: opening app settings');
    await openAppSettings();
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location (one-time)
  Future<Position> getCurrentLocation() async {
    LoggerService.i(
      'LocationService.getCurrentLocation: getting current location',
    );
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      LoggerService.e(
        'LocationService.getCurrentLocation: location permission not granted',
      );
      throw Exception('Location permission not granted');
    }

    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      LoggerService.e(
        'LocationService.getCurrentLocation: location services are disabled',
      );
      throw Exception('Location services are disabled');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    LoggerService.i(
      'LocationService.getCurrentLocation: successfully retrieved position: ${position.latitude}, ${position.longitude}',
    );
    return position;
  }

  /// Get real-time location stream for tracking
  /// Configuration:
  /// - Accuracy: best (for precise GPS tracking)
  /// - Distance filter: 5m (only emit when moved 5+ meters)
  /// - Interval: 1000ms (check every second)
  Stream<Position> getLocationStream() {
    LoggerService.i(
      'LocationService.getLocationStream: creating position stream',
    );
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 1),
        // Set foreground notification config to keep app alive
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Tracking Hike",
          notificationText: "Your hike is being tracked in the background",
          notificationIcon: AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: 2,
        pauseLocationUpdatesAutomatically: false,
        // Helper to enable background location updates
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculate distance between two positions using Haversine formula
  /// Returns distance in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
