import 'package:geolocator/geolocator.dart';
import '../services/logger_service.dart';
import '../mvvm/model/hike.dart';
import '../mvvm/model/track_point.dart';
import '../services/location_service.dart';
import '../services/elevation_service.dart';
import '../services/storage_service.dart';

/// Repository for hike management
///
/// Abstracts LocationService, ElevationService, and StorageService
/// Orchestrates hike lifecycle and statistics calculation
class HikeRepository {
  final LocationService _locationService = LocationService.instance;
  final ElevationService _elevationService = ElevationService.instance;
  final StorageService _storageService = StorageService.instance;

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    LoggerService.i(
      'HikeRepository.hasLocationPermission: checking location permission',
    );
    return await _locationService.checkPermission();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    LoggerService.i(
      'HikeRepository.requestLocationPermission: requesting location permission',
    );
    return await _locationService.requestPermission();
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionDeniedForever() async {
    return await _locationService.isPermissionDeniedForever();
  }

  /// Open app settings
  Future<void> openSettings() async {
    await _locationService.openSettings();
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    LoggerService.i(
      'HikeRepository.isLocationServiceEnabled: checking if location services are enabled',
    );
    return await _locationService.isLocationServiceEnabled();
  }

  /// Start GPS tracking
  /// Returns stream of TrackPoint objects
  Stream<TrackPoint> startTracking() {
    LoggerService.i(
      'HikeRepository.startTracking: resetting elevation smoothing and starting location stream',
    );
    // Reset elevation smoothing for new hike
    _elevationService.reset();

    return _locationService.getLocationStream().map((position) {
      // Apply elevation smoothing
      final smoothedAltitude = _elevationService.smoothElevation(
        position.altitude,
      );

      return TrackPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: smoothedAltitude,
        timestamp: DateTime.now(),
        speed: position.speed,
        accuracy: position.accuracy,
      );
    });
  }

  /// Calculate total distance from track points
  double calculateTotalDistance(List<TrackPoint> points) {
    if (points.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < points.length; i++) {
      final distance = _locationService.calculateDistance(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
      totalDistance += distance;
    }
    return totalDistance;
  }

  /// Calculate distance up to a specific index (for replay)
  double calculateDistanceUpToIndex(List<TrackPoint> points, int endIndex) {
    if (endIndex < 1 || points.isEmpty) return 0.0;
    final subsetPoints = points.sublist(0, endIndex + 1);
    return calculateTotalDistance(subsetPoints);
  }

  /// Calculate cumulative elevation gain and loss from track points
  ({double gain, double loss}) calculateElevationChange(
    List<TrackPoint> points,
  ) {
    return _elevationService.calculateElevationChange(points);
  }

  /// Create and save a hike
  Future<Hike> createHike({
    required String name,
    required List<TrackPoint> points,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    LoggerService.i(
      'HikeRepository.createHike: creating hike "$name" with ${points.length} points',
    );
    // Calculate statistics
    final totalDistance = calculateTotalDistance(points);
    final elevationChange = _elevationService.calculateElevationChange(points);

    // Create hike object
    final hike = Hike.create(
      name: name,
      points: points,
      startTime: startTime,
      endTime: endTime,
      totalDistance: totalDistance,
      elevationGain: elevationChange.gain,
      elevationLoss: elevationChange.loss,
    );

    // Save to storage
    LoggerService.i('HikeRepository.createHike: saving hike to storage');
    await _storageService.saveHike(hike);

    return hike;
  }

  /// Load all saved hikes
  Future<List<Hike>> loadHikes() async {
    return await _storageService.getAllHikes();
  }

  /// Get a specific hike by ID
  Future<Hike?> getHike(String id) async {
    return await _storageService.getHike(id);
  }

  /// Delete a hike
  Future<void> deleteHike(String id) async {
    LoggerService.i('HikeRepository.deleteHike: deleting hike $id');
    await _storageService.deleteHike(id);
  }

  /// Get hike count
  int getHikeCount() {
    final count = _storageService.getHikeCount();
    LoggerService.i('HikeRepository.getHikeCount: current count $count');
    return count;
  }
}
