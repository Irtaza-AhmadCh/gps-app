import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';

class SplashViewModel extends GetxController {
  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('SplashViewModel initialized');
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: Integrate proper Auth/Storage check
    // For now, defaulting to Onboarding for first-time experience
    // In prod: if (StorageService.instance.isLoggedIn) Get.offNamed(AppRoutes.dashboard) else ...
    LoggerService.logInfo('Navigating to Onboarding');
    Get.offNamed(AppRoutes.onboarding);
  }
}
