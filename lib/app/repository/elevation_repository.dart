import '../mvvm/model/track_point.dart';
import '../mvvm/model/elevation_profile_data.dart';
import '../services/elevation_api_service.dart';
import '../services/elevation_service.dart';
import '../services/logger_service.dart';

/// Repository abstracting elevation data access.
///
/// Provides elevation profile data either from:
/// 1. Open-Elevation API (more accurate, requires network)
/// 2. Local GPS altitude fallback (noisy but always available)
class ElevationRepository {
  final ElevationApiService _apiService = ElevationApiService.instance;
  final ElevationService _elevationService = ElevationService.instance;

  /// Get elevation profile for the given track points.
  ///
  /// Tries API first; falls back to local GPS altitudes on failure.
  /// Returns [ElevationProfileData] with elevations, distances, and stats.
  Future<ElevationProfileData> getElevationProfile(
    List<TrackPoint> points,
  ) async {
    LoggerService.i(
      'ElevationRepository.getElevationProfile: requesting profile for ${points.length} points',
    );

    if (points.isEmpty) {
      LoggerService.i(
        'ElevationRepository.getElevationProfile: no points provided',
      );
      return const ElevationProfileData(
        elevations: [],
        distances: [],
        totalAscent: 0,
        totalDescent: 0,
        maxElevation: 0,
        minElevation: 0,
      );
    }

    // Sample points for API efficiency
    final sampled = _apiService.samplePoints(points);
    final distances = _apiService.calculateCumulativeDistances(sampled);

    // Try API first
    final apiElevations = await _apiService.fetchElevations(sampled);

    if (apiElevations != null && apiElevations.length == sampled.length) {
      LoggerService.i(
        'ElevationRepository.getElevationProfile: using API elevation data',
      );
      return ElevationProfileData.fromApiResponse(
        apiElevations
            .asMap()
            .entries
            .map(
              (e) => {
                'elevation': e.value,
                'latitude': sampled[e.key].latitude,
                'longitude': sampled[e.key].longitude,
              },
            )
            .toList(),
        distances,
      );
    }

    // Fallback: use local GPS altitudes with EMA smoothing
    LoggerService.i(
      'ElevationRepository.getElevationProfile: falling back to local GPS altitudes',
    );
    final smoothedElevations = _elevationService.getSmoothedElevations(sampled);

    return ElevationProfileData.fromLocalElevations(
      smoothedElevations,
      distances,
    );
  }
}
