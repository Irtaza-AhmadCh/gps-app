import 'package:get/get.dart';
import '../signup_view_model.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupViewModel>(() => SignupViewModel());
  }
}
