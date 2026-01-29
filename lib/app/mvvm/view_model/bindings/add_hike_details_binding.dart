import 'package:get/get.dart';
import '../add_hike_details_view_model.dart';

class AddHikeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddHikeDetailsViewModel>(() => AddHikeDetailsViewModel());
  }
}
