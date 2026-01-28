import 'package:hive/hive.dart';
import 'track_point.dart';

part 'hike.g.dart'; // ADD THIS LINE - this is what's missing!

/// Represents a complete hike with route and statistics
/// Stored locally using Hive for offline access
@HiveType(typeId: 1) // TrackPoint uses 0, so Hike uses 1
class Hike {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<TrackPoint> points;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  final double totalDistance;

  @HiveField(6)
  final double elevationGain;

  @HiveField(7)
  final double elevationLoss;

  @HiveField(8)
  final int durationSeconds;

  const Hike({
    required this.id,
    required this.name,
    required this.points,
    required this.startTime,
    required this.endTime,
    required this.totalDistance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.durationSeconds,
  });

  Duration get duration => Duration(seconds: durationSeconds);

  factory Hike.create({
    required String name,
    required List<TrackPoint> points,
    required DateTime startTime,
    required DateTime endTime,
    required double totalDistance,
    required double elevationGain,
    required double elevationLoss,
  }) {
    final duration = endTime.difference(startTime);
    return Hike(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      points: points,
      startTime: startTime,
      endTime: endTime,
      totalDistance: totalDistance,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      durationSeconds: duration.inSeconds,
    );
  }

  double get averageSpeed {
    if (durationSeconds == 0) return 0;
    return totalDistance / durationSeconds;
  }

  double get maxElevation {
    if (points.isEmpty) return 0;
    return points.map((p) => p.altitude).reduce((a, b) => a > b ? a : b);
  }

  double get minElevation {
    if (points.isEmpty) return 0;
    return points.map((p) => p.altitude).reduce((a, b) => a < b ? a : b);
  }

  @override
  String toString() {
    return 'Hike(name: $name, distance: ${totalDistance}m, points: ${points.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hike && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}