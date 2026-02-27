import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' as FMTC;
import 'package:gps/app/mvvm/model/map_skin_modal.dart';
import 'logger_service.dart';

class MapTileService {
  MapTileService._();
  static final MapTileService instance = MapTileService._();

  static const String _storeName = 'hikingMapTiles';

  /// Reactive current skin
  final RxString _currentSkinName = 'Default'.obs;

  /// Map of all skins
  final Map<String, MapSkin> _skins = {};
  List<MapSkin> skinlist = [];

  MapSkin get currentSkin {
    if (_skins.containsKey(_currentSkinName.value)) {
      return _skins[_currentSkinName.value]!;
    }
    // Fallback to first registered skin
    if (_skins.isNotEmpty) {
      return _skins.values.first;
    }
    throw Exception('No map skins registered yet!');
  }

  /// Initialize skins (call once)
  void registerSkins(List<MapSkin> skins) {
    skinlist = skins;

    for (final skin in skins) {
      _skins[skin.name] = skin;
    }
    LoggerService.i('MapTileService: registered skins ${_skins.keys}');
  }

  /// Get current skin reactively

  /// Change skin at runtime
  void changeSkin(String skinName) {
    if (_skins.containsKey(skinName)) {
      LoggerService.i('MapTileService: changing skin to $skinName');
      _currentSkinName.value = skinName;
    } else {
      LoggerService.e('MapTileService: skin $skinName not found');
    }
  }

  /// Observe current skin (for UI)
  RxString get currentSkinNameRx => _currentSkinName;

  /// Initialize FMTC backend
  Future<void> init() async {
    LoggerService.i('MapTileService.init: initializing FMTC backend');
    await FMTC.FMTCObjectBoxBackend().initialise();
    final storeExists = await FMTC.FMTCStore(_storeName).manage.ready;
    if (!storeExists) await FMTC.FMTCStore(_storeName).manage.create();
  }

  /// Returns TileLayer based on current skin
  TileLayer getTileLayer() {
    final skin = currentSkin;
    return TileLayer(
      urlTemplate: skin.urlTemplate,
      subdomains: skin.subdomains,
      userAgentPackageName: 'com.example.gps',
      tileProvider: FMTC.FMTCStore(_storeName).getTileProvider(),
      maxZoom: 19,
      minZoom: 1,
      errorTileCallback: (tile, error, stackTrace) {
        LoggerService.e(
          'Tile load error: $error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  String getAttributionText() => currentSkin.attribution;

  // ── Offline Region Download Methods ──

  /// Estimate the number of tiles for a given bounds and zoom range.
  ///
  /// This is a rough estimate: for each zoom level, we count the number of
  /// tiles in the bounding box using the standard slippy-map tile formula.
  int estimateTileCount({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    required int minZoom,
    required int maxZoom,
  }) {
    LoggerService.i(
      'MapTileService.estimateTileCount: estimating for zoom $minZoom-$maxZoom',
    );
    int total = 0;
    for (int z = minZoom; z <= maxZoom; z++) {
      final xMin = _tileX(minLng, z).floor();
      final xMax = _tileX(maxLng, z).floor();
      final yMin = _tileY(maxLat, z).floor();
      final yMax = _tileY(minLat, z).floor();
      total += (xMax - xMin + 1) * (yMax - yMin + 1);
    }
    LoggerService.i('MapTileService.estimateTileCount: estimated $total tiles');
    return total;
  }

  /// Create a dedicated FMTC store for a downloaded region
  Future<void> createRegionStore(String storeName) async {
    LoggerService.i(
      'MapTileService.createRegionStore: creating store "$storeName"',
    );
    final storeExists = await FMTC.FMTCStore(storeName).manage.ready;
    if (!storeExists) {
      await FMTC.FMTCStore(storeName).manage.create();
    }
  }

  /// Delete a region's FMTC store and all its cached tiles
  Future<void> deleteRegionStore(String storeName) async {
    LoggerService.i(
      'MapTileService.deleteRegionStore: deleting store "$storeName"',
    );
    try {
      final storeExists = await FMTC.FMTCStore(storeName).manage.ready;
      if (storeExists) {
        await FMTC.FMTCStore(storeName).manage.delete();
      }
    } catch (e, stackTrace) {
      LoggerService.e(
        'MapTileService.deleteRegionStore: failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get size of the main cache store in bytes (approximate)
  Future<int> getMainStoreSizeBytes() async {
    LoggerService.i('MapTileService.getMainStoreSizeBytes: checking size');
    try {
      final store = FMTC.FMTCStore(_storeName);
      final length = await store.stats.length;
      return length;
    } catch (e) {
      LoggerService.e('MapTileService.getMainStoreSizeBytes: error: $e');
      return 0;
    }
  }

  // ── Math helpers for tile estimation ──
  static double _degToRad(double deg) => deg * math.pi / 180;
  static double _tileX(double lng, int z) => (lng + 180) / 360 * (1 << z);
  static double _tileY(double lat, int z) {
    final latRad = _degToRad(lat);
    return (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) *
        (1 << z) /
        2;
  }
}
