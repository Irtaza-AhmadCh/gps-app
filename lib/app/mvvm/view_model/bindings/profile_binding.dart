import 'package:get/get.dart';
import '../profile_view_model.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel());
  }
}
