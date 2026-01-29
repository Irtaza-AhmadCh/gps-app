import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';

class ProfileViewModel extends GetxController {
  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('ProfileViewModel initialized');
  }

  void logout() {
    LoggerService.logInfo('Logging out');
    Get.offAllNamed(AppRoutes.login);
  }
}
