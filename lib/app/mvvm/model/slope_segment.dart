import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Difficulty classification for slope segments
enum SlopeDifficulty {
  easy, // 0–5%
  moderate, // 5–15%
  steep, // 15–30%
  verySteep, // 30–45%
  extreme, // >45%
}

/// Extension to map difficulty to color and label
extension SlopeDifficultyExtension on SlopeDifficulty {
  Color get color {
    switch (this) {
      case SlopeDifficulty.easy:
        return AppColors.slopeEasy;
      case SlopeDifficulty.moderate:
        return AppColors.slopeModerate;
      case SlopeDifficulty.steep:
        return AppColors.slopeSteep;
      case SlopeDifficulty.verySteep:
        return AppColors.slopeVerySteep;
      case SlopeDifficulty.extreme:
        return AppColors.slopeExtreme;
    }
  }

  String get label {
    switch (this) {
      case SlopeDifficulty.easy:
        return 'Easy';
      case SlopeDifficulty.moderate:
        return 'Moderate';
      case SlopeDifficulty.steep:
        return 'Steep';
      case SlopeDifficulty.verySteep:
        return 'Very Steep';
      case SlopeDifficulty.extreme:
        return 'Extreme';
    }
  }

  String get range {
    switch (this) {
      case SlopeDifficulty.easy:
        return '0-5%';
      case SlopeDifficulty.moderate:
        return '5-15%';
      case SlopeDifficulty.steep:
        return '15-30%';
      case SlopeDifficulty.verySteep:
        return '30-45%';
      case SlopeDifficulty.extreme:
        return '>45%';
    }
  }
}

/// Represents a segment of the route with a calculated slope
class SlopeSegment {
  /// Index of the first point in this segment (in the TrackPoint list)
  final int startIndex;

  /// Index of the last point in this segment (inclusive)
  final int endIndex;

  /// Average slope percentage for this segment
  final double slopePercent;

  /// Classified difficulty based on slope
  final SlopeDifficulty difficulty;

  const SlopeSegment({
    required this.startIndex,
    required this.endIndex,
    required this.slopePercent,
    required this.difficulty,
  });

  @override
  String toString() {
    return 'SlopeSegment($startIndex→$endIndex, ${slopePercent.toStringAsFixed(1)}%, ${difficulty.label})';
  }
}
