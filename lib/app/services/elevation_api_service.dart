import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_urls.dart';
import '../mvvm/model/track_point.dart';
import '../mvvm/model/elevation_request_model.dart';
import 'logger_service.dart';
import 'location_service.dart';

/// Service for fetching elevation data from Open-Elevation API
///
/// Features:
/// - Samples route points to reduce API payload
/// - Batches requests into chunks of 100 coordinates
/// - Calculates cumulative distances for the chart X-axis
/// - Falls back gracefully on error
class ElevationApiService {
  ElevationApiService._();
  static final ElevationApiService instance = ElevationApiService._();

  final LocationService _locationService = LocationService.instance;

  /// Maximum coordinates per single API request
  static const int _batchSize = 100;

  /// Target number of sampled points for a route
  static const int _targetSampleCount = 100;

  /// Sample track points to reduce API load
  ///
  /// Always includes first and last point.
  /// For routes with fewer than [_targetSampleCount] points, returns all.
  List<TrackPoint> samplePoints(List<TrackPoint> points) {
    LoggerService.i(
      'ElevationApiService.samplePoints: sampling ${points.length} points (target: $_targetSampleCount)',
    );

    if (points.length <= _targetSampleCount) {
      return List.from(points);
    }

    final sampled = <TrackPoint>[];
    final step = (points.length - 1) / (_targetSampleCount - 1);

    for (int i = 0; i < _targetSampleCount - 1; i++) {
      sampled.add(points[(i * step).round()]);
    }
    sampled.add(points.last); // Always include last point

    LoggerService.i(
      'ElevationApiService.samplePoints: sampled down to ${sampled.length} points',
    );
    return sampled;
  }

  /// Calculate cumulative distances between consecutive track points
  ///
  /// Returns list of distances in meters where distances[0] = 0.0
  List<double> calculateCumulativeDistances(List<TrackPoint> points) {
    LoggerService.i(
      'ElevationApiService.calculateCumulativeDistances: calculating for ${points.length} points',
    );

    final distances = <double>[0.0];
    double cumulative = 0.0;

    for (int i = 1; i < points.length; i++) {
      final dist = _locationService.calculateDistance(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
      cumulative += dist;
      distances.add(cumulative);
    }

    return distances;
  }

  /// Fetch elevations from Open-Elevation API for the given track points
  ///
  /// Returns a list of elevation values (meters) or null on failure.
  /// Handles batching internally for large coordinate sets.
  Future<List<double>?> fetchElevations(List<TrackPoint> points) async {
    LoggerService.i(
      'ElevationApiService.fetchElevations: fetching for ${points.length} points',
    );

    try {
      final allElevations = <double>[];

      // Split into batches
      for (int i = 0; i < points.length; i += _batchSize) {
        final end = (i + _batchSize).clamp(0, points.length);
        final batch = points.sublist(i, end);

        LoggerService.i(
          'ElevationApiService.fetchElevations: batch ${(i ~/ _batchSize) + 1}, points $i-$end',
        );

        final coords = batch
            .map((p) => (lat: p.latitude, lng: p.longitude))
            .toList();

        final request = ElevationRequestModel.fromCoordinates(coords);

        final response = await http.post(
          Uri.parse(AppUrls.openElevationLookup),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final results = data['results'] as List<dynamic>;

          for (final r in results) {
            allElevations.add((r['elevation'] as num).toDouble());
          }

          LoggerService.i(
            'ElevationApiService.fetchElevations: batch returned ${results.length} elevations',
          );
        } else {
          LoggerService.e(
            'ElevationApiService.fetchElevations: API error ${response.statusCode}: ${response.body}',
          );
          return null; // Fail entire request on any batch error
        }

        // Small delay between batches to avoid rate limiting
        if (end < points.length) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      LoggerService.i(
        'ElevationApiService.fetchElevations: successfully fetched ${allElevations.length} elevations',
      );
      return allElevations;
    } catch (e, stackTrace) {
      LoggerService.e(
        'ElevationApiService.fetchElevations: failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
