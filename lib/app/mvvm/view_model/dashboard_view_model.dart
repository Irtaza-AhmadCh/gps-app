import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';

class DashboardViewModel extends GetxController {
  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('DashboardViewModel initialized');
  }

  void startHike() {
    LoggerService.logInfo('Starting hike from Dashboard');
    Get.toNamed(AppRoutes.tracking); // Navigate to existing tracking
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }
}
