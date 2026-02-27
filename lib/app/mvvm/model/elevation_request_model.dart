import 'dart:convert';

/// Request model for Open-Elevation API batch lookup
///
/// API expects: POST with body { "locations": [{"latitude": x, "longitude": y}, ...] }
class ElevationRequestModel {
  final List<ElevationPoint> locations;

  const ElevationRequestModel({required this.locations});

  /// Convert to JSON for POST body
  Map<String, dynamic> toJson() {
    return {'locations': locations.map((p) => p.toJson()).toList()};
  }

  /// Encode to UTF-8 bytes for HttpsCalls
  List<int> toUtf8() {
    return utf8.encode(jsonEncode(toJson()));
  }

  /// Create from a list of lat/lng pairs
  factory ElevationRequestModel.fromCoordinates(
    List<({double lat, double lng})> coords,
  ) {
    return ElevationRequestModel(
      locations: coords
          .map((c) => ElevationPoint(latitude: c.lat, longitude: c.lng))
          .toList(),
    );
  }
}

/// A single coordinate point for the elevation request
class ElevationPoint {
  final double latitude;
  final double longitude;

  const ElevationPoint({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
