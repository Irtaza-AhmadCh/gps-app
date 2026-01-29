import 'package:get/get.dart';
import '../hike_details_view_model.dart';

class HikeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HikeDetailsViewModel>(() => HikeDetailsViewModel());
  }
}
