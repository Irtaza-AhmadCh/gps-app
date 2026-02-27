import '../mvvm/model/track_point.dart';
import '../mvvm/model/slope_segment.dart';
import 'logger_service.dart';
import 'location_service.dart';

/// Service for calculating slope/gradient between route points
///
/// Computes slope percentage from elevation change and horizontal distance,
/// classifies segments into difficulty buckets, and merges consecutive
/// segments with the same difficulty for rendering performance.
class SlopeService {
  SlopeService._();
  static final SlopeService instance = SlopeService._();

  final LocationService _locationService = LocationService.instance;

  /// Minimum horizontal distance (meters) between points to calculate slope.
  /// Prevents division by near-zero and filters GPS noise.
  static const double _minHorizontalDistance = 5.0;

  /// Classify a slope percentage into a difficulty bucket
  SlopeDifficulty classifySlope(double slopePercent) {
    final absSlope = slopePercent.abs();
    if (absSlope <= 5) return SlopeDifficulty.easy;
    if (absSlope <= 15) return SlopeDifficulty.moderate;
    if (absSlope <= 30) return SlopeDifficulty.steep;
    if (absSlope <= 45) return SlopeDifficulty.verySteep;
    return SlopeDifficulty.extreme;
  }

  /// Calculate slope percentage between two track points
  ///
  /// Formula: slope% = (elevationChange / horizontalDistance) * 100
  /// Returns null if horizontal distance is too small (GPS noise)
  double? calculateSlopeBetween(TrackPoint a, TrackPoint b) {
    final horizontalDistance = _locationService.calculateDistance(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );

    if (horizontalDistance < _minHorizontalDistance) {
      return null; // Too close, skip
    }

    final elevationChange = b.altitude - a.altitude;
    return (elevationChange / horizontalDistance) * 100;
  }

  /// Generate slope segments from a list of track points
  ///
  /// Algorithm:
  /// 1. Calculate slope between each consecutive pair
  /// 2. Classify into difficulty bucket
  /// 3. Merge consecutive segments with same bucket
  ///
  /// Returns a reduced list of merged SlopeSegments
  List<SlopeSegment> generateSlopeSegments(List<TrackPoint> points) {
    LoggerService.i(
      'SlopeService.generateSlopeSegments: processing ${points.length} points',
    );

    if (points.length < 2) {
      LoggerService.i(
        'SlopeService.generateSlopeSegments: not enough points, returning empty',
      );
      return [];
    }

    // Step 1: Calculate per-pair slopes and classify
    final List<_RawSegment> rawSegments = [];

    for (int i = 0; i < points.length - 1; i++) {
      final slope = calculateSlopeBetween(points[i], points[i + 1]);

      if (slope == null) {
        // Points too close — assign same difficulty as previous or default to easy
        final difficulty = rawSegments.isNotEmpty
            ? rawSegments.last.difficulty
            : SlopeDifficulty.easy;
        rawSegments.add(
          _RawSegment(index: i, slopePercent: 0.0, difficulty: difficulty),
        );
      } else {
        rawSegments.add(
          _RawSegment(
            index: i,
            slopePercent: slope,
            difficulty: classifySlope(slope),
          ),
        );
      }
    }

    if (rawSegments.isEmpty) {
      return [];
    }

    // Step 2: Merge consecutive segments with same difficulty
    final List<SlopeSegment> merged = [];
    int mergeStart = 0;
    double slopeSum = rawSegments.first.slopePercent;
    int slopeCount = 1;

    for (int i = 1; i < rawSegments.length; i++) {
      if (rawSegments[i].difficulty == rawSegments[mergeStart].difficulty) {
        // Same bucket — extend the merge
        slopeSum += rawSegments[i].slopePercent;
        slopeCount++;
      } else {
        // Different bucket — flush the merged segment
        merged.add(
          SlopeSegment(
            startIndex: rawSegments[mergeStart].index,
            endIndex: rawSegments[i - 1].index + 1, // +1 to include end point
            slopePercent: slopeSum / slopeCount,
            difficulty: rawSegments[mergeStart].difficulty,
          ),
        );
        mergeStart = i;
        slopeSum = rawSegments[i].slopePercent;
        slopeCount = 1;
      }
    }

    // Flush last segment
    merged.add(
      SlopeSegment(
        startIndex: rawSegments[mergeStart].index,
        endIndex: rawSegments.last.index + 1,
        slopePercent: slopeSum / slopeCount,
        difficulty: rawSegments[mergeStart].difficulty,
      ),
    );

    LoggerService.i(
      'SlopeService.generateSlopeSegments: generated ${merged.length} merged segments from ${rawSegments.length} raw pairs',
    );

    return merged;
  }
}

/// Internal helper for unmerged slope data
class _RawSegment {
  final int index;
  final double slopePercent;
  final SlopeDifficulty difficulty;

  const _RawSegment({
    required this.index,
    required this.slopePercent,
    required this.difficulty,
  });
}
