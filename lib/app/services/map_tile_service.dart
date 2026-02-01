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

  // Optional: cache stats, clear cache...
}
