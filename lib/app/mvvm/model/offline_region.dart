import 'package:hive/hive.dart';

part 'offline_region.g.dart';

/// Represents a downloaded offline map region
/// Stored in Hive for persistent tracking of downloaded regions
@HiveType(typeId: 2)
class OfflineRegion {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double minLat;

  @HiveField(3)
  final double maxLat;

  @HiveField(4)
  final double minLng;

  @HiveField(5)
  final double maxLng;

  @HiveField(6)
  final int minZoom;

  @HiveField(7)
  final int maxZoom;

  @HiveField(8)
  final int tileCount;

  @HiveField(9)
  final int sizeBytes;

  @HiveField(10)
  final DateTime downloadDate;

  @HiveField(11)
  final String storeName;

  const OfflineRegion({
    required this.id,
    required this.name,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.minZoom,
    required this.maxZoom,
    required this.tileCount,
    required this.sizeBytes,
    required this.downloadDate,
    required this.storeName,
  });

  /// Human-readable size
  String get formattedSize {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  String toString() {
    return 'OfflineRegion(name: $name, tiles: $tileCount, size: $formattedSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfflineRegion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
