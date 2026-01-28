import 'package:get/get.dart';
import '../hike_tracking_controller.dart';

/// Binding for Live Tracking View
class HikeTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HikeTrackingController>(() => HikeTrackingController());
  }
}
