import 'package:get/get.dart';
import '../hikes_list_view_model.dart';

class HikesListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HikesListViewModel>(() => HikesListViewModel());
  }
}
