/// Holds the result of an elevation profile computation.
///
/// Contains:
/// - [elevations]: smoothed elevation values per sampled point (meters)
/// - [distances]: cumulative horizontal distance per point (meters)
/// - [totalAscent]: sum of all positive elevation changes (meters)
/// - [totalDescent]: sum of all negative elevation changes (meters)
/// - [maxElevation]: highest point in the profile (meters)
/// - [minElevation]: lowest point in the profile (meters)
class ElevationProfileData {
  final List<double> elevations;
  final List<double> distances;
  final double totalAscent;
  final double totalDescent;
  final double maxElevation;
  final double minElevation;

  const ElevationProfileData({
    required this.elevations,
    required this.distances,
    required this.totalAscent,
    required this.totalDescent,
    required this.maxElevation,
    required this.minElevation,
  });

  /// Parse from Open-Elevation API response
  ///
  /// API returns: { "results": [{"latitude": x, "longitude": y, "elevation": z}, ...] }
  factory ElevationProfileData.fromApiResponse(
    List<dynamic> results,
    List<double> cumulativeDistances,
  ) {
    final elevations = results
        .map<double>((r) => (r['elevation'] as num).toDouble())
        .toList();

    // Calculate ascent/descent
    double totalAscent = 0.0;
    double totalDescent = 0.0;
    double maxElev = elevations.isNotEmpty ? elevations.first : 0.0;
    double minElev = elevations.isNotEmpty ? elevations.first : 0.0;

    for (int i = 1; i < elevations.length; i++) {
      final diff = elevations[i] - elevations[i - 1];
      if (diff > 0) {
        totalAscent += diff;
      } else {
        totalDescent += diff.abs();
      }
      if (elevations[i] > maxElev) maxElev = elevations[i];
      if (elevations[i] < minElev) minElev = elevations[i];
    }

    return ElevationProfileData(
      elevations: elevations,
      distances: cumulativeDistances,
      totalAscent: totalAscent,
      totalDescent: totalDescent,
      maxElevation: maxElev,
      minElevation: minElev,
    );
  }

  /// Create from existing GPS-recorded track points (local fallback)
  factory ElevationProfileData.fromLocalElevations(
    List<double> elevations,
    List<double> distances,
  ) {
    double totalAscent = 0.0;
    double totalDescent = 0.0;
    double maxElev = elevations.isNotEmpty ? elevations.first : 0.0;
    double minElev = elevations.isNotEmpty ? elevations.first : 0.0;

    for (int i = 1; i < elevations.length; i++) {
      final diff = elevations[i] - elevations[i - 1];
      if (diff > 0) {
        totalAscent += diff;
      } else {
        totalDescent += diff.abs();
      }
      if (elevations[i] > maxElev) maxElev = elevations[i];
      if (elevations[i] < minElev) minElev = elevations[i];
    }

    return ElevationProfileData(
      elevations: elevations,
      distances: distances,
      totalAscent: totalAscent,
      totalDescent: totalDescent,
      maxElevation: maxElev,
      minElevation: minElev,
    );
  }

  @override
  String toString() {
    return 'ElevationProfileData(points: ${elevations.length}, ascent: ${totalAscent.toStringAsFixed(0)}m, descent: ${totalDescent.toStringAsFixed(0)}m, max: ${maxElevation.toStringAsFixed(0)}m, min: ${minElevation.toStringAsFixed(0)}m)';
  }
}
