import 'package:hive/hive.dart';

part 'track_point.g.dart';

/// Represents a single GPS tracking point
/// Contains location coordinates, altitude, and timestamp
@HiveType(typeId: 0)
class TrackPoint {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double altitude;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final double? speed; // m/s, optional

  @HiveField(5)
  final double? accuracy; // meters, optional

  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
    this.speed,
    this.accuracy,
  });

  /// Create TrackPoint from Geolocator Position
  factory TrackPoint.fromPosition({
    required double latitude,
    required double longitude,
    required double altitude,
    required DateTime timestamp,
    double? speed,
    double? accuracy,
  }) {
    return TrackPoint(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      timestamp: timestamp,
      speed: speed,
      accuracy: accuracy,
    );
  }

  @override
  String toString() {
    return 'TrackPoint(lat: $latitude, lng: $longitude, alt: $altitude, acc: $accuracy, time: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackPoint &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.altitude == altitude &&
        other.timestamp == timestamp &&
        other.speed == speed &&
        other.accuracy == accuracy;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      altitude,
      timestamp,
      speed,
      accuracy,
    );
  }
}
