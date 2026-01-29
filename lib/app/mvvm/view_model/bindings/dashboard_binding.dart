import 'package:get/get.dart';
import '../dashboard_view_model.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardViewModel>(() => DashboardViewModel());
  }
}
