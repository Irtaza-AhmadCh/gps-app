import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as FMTC;
import 'logger_service.dart';

/// Service for map tile configuration and caching
///
/// Uses OpenStreetMap tiles with automatic caching for offline use.
///
/// Offline Behavior:
/// - Tiles are cached automatically during use
/// - If offline and tiles are unavailable:
///   - Show placeholder background (gray)
///   - Overlay message: "Map not available offline. Pre-cache area before hiking."
///   - Prevents blank/broken map UX
/// - Pre-caching requires manual implementation (future enhancement)
class MapTileService {
  MapTileService._();
  static final MapTileService instance = MapTileService._();

  /// Store name for cached tiles
  static const String _storeName = 'hikingMapTiles';

  /// Initialize tile caching
  Future<void> init() async {
    LoggerService.i('MapTileService.init: initializing FMTC backend');
    await FMTC.FMTCObjectBoxBackend().initialise();

    // Create store if it doesn't exist
    final storeExists = await FMTC.FMTCStore(_storeName).manage.ready;
    LoggerService.i(
      'MapTileService.init: store "$_storeName" exists: $storeExists',
    );
    if (!storeExists) {
      LoggerService.i('MapTileService.init: creating store "$_storeName"');
      await FMTC.FMTCStore(_storeName).manage.create();
    }
  }

  /// Get tile layer configuration for flutter_map
  ///
  /// Uses OpenStreetMap tiles with caching enabled
  TileLayer getTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.gps',

      // Use cached tile provider for offline support
      tileProvider: FMTC.FMTCStore(_storeName).getTileProvider(),

      // Tile display settings
      maxZoom: 19,
      minZoom: 1,

      // Error tile builder - shows when tile fails to load
      errorTileCallback: (tile, error, stackTrace) {
        // Log error but don't crash
        LoggerService.e(
          'MapTileService.getTileLayer: Tile load error: $error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Get attribution text for OpenStreetMap
  String getAttributionText() {
    return '© OpenStreetMap contributors';
  }

  /// Check if store is ready
  Future<bool> isStoreReady() async {
    return await FMTC.FMTCStore(_storeName).manage.ready;
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    LoggerService.i('MapTileService.getCacheStats: retrieving tile count');
    final stats = await FMTC.FMTCStore(_storeName).stats.length;
    LoggerService.i(
      'MapTileService.getCacheStats: currently $stats tiles cached',
    );
    return {'cachedTiles': stats};
  }

  /// Clear all cached tiles (for settings/cleanup)
  Future<void> clearCache() async {
    LoggerService.i('MapTileService.clearCache: clearing store "$_storeName"');
    await FMTC.FMTCStore(_storeName).manage.delete();
    await FMTC.FMTCStore(_storeName).manage.create();
    LoggerService.i(
      'MapTileService.clearCache: cache cleared and store recreated',
    );
  }
}
