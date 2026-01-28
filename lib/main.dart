import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    // Initialize Hive and Storage Service (opens boxes, registers adapters)
    await StorageService.instance.init();

    // Initialize FMTC and Map Tile Service (initializes backend, creates store)
    await MapTileService.instance.init();

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
    return GetMaterialApp(
      title: 'Hiking Tracker',
      debugShowCheckedModeBanner: false,

      // Dark theme optimized for outdoor use
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.cardBackground,
          error: AppColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
        ),
      ),

      // GetX routing
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
    );
  }
}
