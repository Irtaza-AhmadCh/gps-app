import 'package:get/get.dart';
import '../permission_view_model.dart';

class PermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionViewModel>(() => PermissionViewModel());
  }
}
