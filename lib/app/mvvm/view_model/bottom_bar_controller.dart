import 'package:get/get.dart';
import '../../services/logger_service.dart';

/// BottomBarController
/// Manages the bottom navigation bar state and tab switching
class BottomBarController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('BottomBarController.onInit: Initializing');
  }

  /// Change the current tab index
  void changeTab(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      LoggerService.logInfo(
        'BottomBarController.changeTab: Switched to tab $index',
      );
    }
  }

  @override
  void onClose() {
    LoggerService.logInfo('BottomBarController.onClose: Disposing');
    super.onClose();
  }
}
