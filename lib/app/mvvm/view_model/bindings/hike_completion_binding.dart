import 'package:get/get.dart';
import '../hike_completion_view_model.dart';

class HikeCompletionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HikeCompletionViewModel>(() => HikeCompletionViewModel());
  }
}
