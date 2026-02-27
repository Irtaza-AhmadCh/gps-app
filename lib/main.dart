import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gps/app/mvvm/model/map_skin_modal.dart';
import 'app/config/app_routes.dart';
import 'app/config/app_pages.dart';
import 'app/config/app_colors.dart';
import 'app/services/storage_service.dart';
import 'app/services/map_tile_service.dart';
import 'app/services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    LoggerService.i('main: Starting application initialization');

    await StorageService.instance.init();
    await MapTileService.instance.init();

    final skins = [
      MapSkin(
        name: 'Default',
        urlTemplate:
            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
        attribution: '© OpenStreetMap contributors',
      ),
      MapSkin(
        name: 'Light',
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        attribution: '© OpenStreetMap contributors',
      ),
      MapSkin(
        name: 'Satellite',
        urlTemplate:
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        attribution: '© ESRI, Maxar, Earthstar Geographics',
      ),
      MapSkin(
        name: 'Topo',
        urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
        subdomains: const ['a', 'b', 'c'],
        attribution: '© OpenTopoMap (CC-BY-SA)',
      ),
    ];

    MapTileService.instance.registerSkins(skins);

    LoggerService.i('main: Application initialization complete');
  } catch (e, stackTrace) {
    LoggerService.e(
      'main: Initialization failed: $e',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(const HikingTrackerApp());
}

class HikingTrackerApp extends StatelessWidget {
  const HikingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X base (recommended)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'Hiking Tracker',
          debugShowCheckedModeBanner: false,

          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.dimGrey,
              error: AppColors.error,
            ),
            appBarTheme: const AppBarTheme(elevation: 0),
          ),

          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
