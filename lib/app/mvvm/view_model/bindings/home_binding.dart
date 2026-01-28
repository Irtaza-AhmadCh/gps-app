import 'package:get/get.dart';
import '../home_controller.dart';

/// Binding for Home View
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
