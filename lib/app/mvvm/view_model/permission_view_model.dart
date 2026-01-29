import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';

class PermissionViewModel extends GetxController {
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('PermissionViewModel initialized');
  }

  void requestLocationPermission() async {
    isLoading.value = true;
    LoggerService.logInfo('Requesting location permission');

    // Mock permission request for now or use actual logic if package is available
    // Assuming successful for flow
    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;
    LoggerService.logInfo('Permission granted');
    Get.offAllNamed(AppRoutes.dashboard);
  }
}
