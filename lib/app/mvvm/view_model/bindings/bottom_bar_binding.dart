import 'package:get/get.dart';
import '../bottom_bar_controller.dart';
import '../home_controller.dart';
import '../hike_tracking_controller.dart';
import '../profile_view_model.dart';

/// BottomBarBinding
/// Injects all controllers needed for bottom navigation tabs
class BottomBarBinding extends Bindings {
  @override
  void dependencies() {
    // Bottom bar controller
    Get.lazyPut<BottomBarController>(() => BottomBarController());

    // Tab controllers
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HikeTrackingController>(() => HikeTrackingController());
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel());
  }
}
