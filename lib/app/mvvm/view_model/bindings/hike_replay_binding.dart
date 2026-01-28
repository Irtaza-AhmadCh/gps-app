import 'package:get/get.dart';
import '../hike_replay_controller.dart';

/// Binding for Hike Summary/Replay View
class HikeReplayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HikeReplayController>(() => HikeReplayController());
  }
}
