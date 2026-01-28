import 'logger_service.dart';
import '../mvvm/model/track_point.dart';

/// Service for elevation calculation and smoothing
///
/// GPS altitude is inherently noisy with ±10-50m accuracy.
/// This service applies smoothing and filtering to provide realistic elevation profiles.
///
/// Techniques used:
/// 1. Exponential Moving Average (EMA) for smoothing
/// 2. Minimum threshold filtering to ignore GPS noise
class ElevationService {
  ElevationService._();
  static final ElevationService instance = ElevationService._();

  /// EMA smoothing factor (alpha)
  /// - Higher alpha (closer to 1.0) = more responsive, less smoothing
  /// - Lower alpha (closer to 0.0) = more smoothing, less responsive
  /// - 0.3 balances noise reduction with real elevation changes
  static const double _alpha = 0.3;

  /// Minimum elevation change threshold in meters
  /// Changes smaller than this are considered GPS noise and ignored
  static const double _minElevationThreshold = 2.0;

  double? _previousSmoothedElevation;

  /// Apply Exponential Moving Average smoothing to raw GPS altitude
  ///
  /// Formula: smoothed = alpha * raw + (1 - alpha) * previous
  ///
  /// This reduces GPS altitude jitter while preserving real elevation changes
  double smoothElevation(double rawAltitude) {
    if (_previousSmoothedElevation == null) {
      _previousSmoothedElevation = rawAltitude;
      return rawAltitude;
    }

    final smoothed =
        _alpha * rawAltitude + (1 - _alpha) * _previousSmoothedElevation!;
    _previousSmoothedElevation = smoothed;
    return smoothed;
  }

  /// Reset smoothing state (call when starting new hike)
  void reset() {
    LoggerService.i(
      'ElevationService.reset: resetting elevation smoothing state',
    );
    _previousSmoothedElevation = null;
  }

  /// Calculate cumulative elevation gain and loss from track points
  ///
  /// Only counts elevation changes greater than threshold to filter GPS noise
  ///
  /// Returns: (elevationGain, elevationLoss) in meters
  ({double gain, double loss}) calculateElevationChange(
    List<TrackPoint> points,
  ) {
    if (points.length < 2) {
      return (gain: 0.0, loss: 0.0);
    }

    double totalGain = 0.0;
    double totalLoss = 0.0;

    for (int i = 1; i < points.length; i++) {
      final previousAlt = points[i - 1].altitude;
      final currentAlt = points[i].altitude;
      final change = currentAlt - previousAlt;

      // Only count changes above threshold (filter GPS noise)
      if (change.abs() >= _minElevationThreshold) {
        if (change > 0) {
          totalGain += change;
        } else {
          totalLoss += change.abs();
        }
      }
    }

    return (gain: totalGain, loss: totalLoss);
  }

  /// Calculate elevation gain and loss for a subset of points (for replay)
  ({double gain, double loss}) calculateElevationChangeUpToIndex(
    List<TrackPoint> points,
    int endIndex,
  ) {
    if (endIndex < 1 || points.isEmpty) {
      return (gain: 0.0, loss: 0.0);
    }

    final subsetPoints = points.sublist(0, endIndex + 1);
    return calculateElevationChange(subsetPoints);
  }

  /// Get smoothed elevation values for all points (for chart display)
  List<double> getSmoothedElevations(List<TrackPoint> points) {
    LoggerService.i(
      'ElevationService.getSmoothedElevations: smoothing ${points.length} points for chart',
    );
    reset(); // Reset state before processing
    return points.map((point) => smoothElevation(point.altitude)).toList();
  }
}
