import 'package:hive_flutter/hive_flutter.dart';
import '../mvvm/model/offline_region.dart';
import '../services/map_tile_service.dart';
import '../services/logger_service.dart';

/// Repository for managing offline map region downloads.
///
/// Abstracts FMTC store management and Hive region metadata storage.
/// Data flow: ViewModel → Repository → MapTileService (FMTC) + Hive
class OfflineRegionRepository {
  final MapTileService _tileService = MapTileService.instance;

  static const String _regionsBoxName = 'offline_regions';

  /// Initialize the Hive box for region metadata
  Future<void> init() async {
    LoggerService.i('OfflineRegionRepository.init: opening regions box');
    if (!Hive.isBoxOpen(_regionsBoxName)) {
      await Hive.openBox<OfflineRegion>(_regionsBoxName);
    }
  }

  Box<OfflineRegion> get _regionsBox =>
      Hive.box<OfflineRegion>(_regionsBoxName);

  /// Get all saved offline regions (sorted by download date, newest first)
  List<OfflineRegion> getAllRegions() {
    LoggerService.i(
      'OfflineRegionRepository.getAllRegions: retrieving all regions',
    );
    final regions = _regionsBox.values.toList();
    regions.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));
    LoggerService.i(
      'OfflineRegionRepository.getAllRegions: found ${regions.length} regions',
    );
    return regions;
  }

  /// Estimate tile count for a region
  int estimateTileCount({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    int minZoom = 10,
    int maxZoom = 16,
  }) {
    LoggerService.i(
      'OfflineRegionRepository.estimateTileCount: estimating tiles',
    );
    return _tileService.estimateTileCount(
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
  }

  /// Save a downloaded region's metadata
  Future<OfflineRegion> saveRegion({
    required String name,
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    required int minZoom,
    required int maxZoom,
    required int tileCount,
    required int sizeBytes,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final storeName = 'region_$id';

    LoggerService.i(
      'OfflineRegionRepository.saveRegion: saving region "$name" (store: $storeName)',
    );

    // Create FMTC store for this region
    await _tileService.createRegionStore(storeName);

    final region = OfflineRegion(
      id: id,
      name: name,
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
      minZoom: minZoom,
      maxZoom: maxZoom,
      tileCount: tileCount,
      sizeBytes: sizeBytes,
      downloadDate: DateTime.now(),
      storeName: storeName,
    );

    await _regionsBox.put(id, region);
    LoggerService.i(
      'OfflineRegionRepository.saveRegion: region saved: $region',
    );
    return region;
  }

  /// Delete a region and its FMTC store
  Future<void> deleteRegion(String regionId) async {
    LoggerService.i(
      'OfflineRegionRepository.deleteRegion: deleting region $regionId',
    );
    final region = _regionsBox.get(regionId);
    if (region != null) {
      await _tileService.deleteRegionStore(region.storeName);
      await _regionsBox.delete(regionId);
      LoggerService.i(
        'OfflineRegionRepository.deleteRegion: region and store deleted',
      );
    } else {
      LoggerService.e(
        'OfflineRegionRepository.deleteRegion: region $regionId not found',
      );
    }
  }

  /// Get total storage used by all downloaded regions
  int getTotalStorageUsed() {
    LoggerService.i('OfflineRegionRepository.getTotalStorageUsed: calculating');
    final regions = _regionsBox.values.toList();
    int total = 0;
    for (final region in regions) {
      total += region.sizeBytes;
    }
    LoggerService.i(
      'OfflineRegionRepository.getTotalStorageUsed: total ${total} bytes',
    );
    return total;
  }

  /// Get region count
  int getRegionCount() => _regionsBox.length;
}
