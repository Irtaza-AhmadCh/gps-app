import 'package:get/get.dart';
import '../mvvm/view/home_view.dart';
import '../mvvm/view/live_tracking_view.dart';
import '../mvvm/view/hike_summary_view.dart';
import '../mvvm/view_model/bindings/home_binding.dart';
import '../mvvm/view_model/bindings/hike_tracking_binding.dart';
import '../mvvm/view_model/bindings/hike_replay_binding.dart';
import 'app_routes.dart';

/// App pages configuration with GetX bindings
class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.tracking,
      page: () => const LiveTrackingView(),
      binding: HikeTrackingBinding(),
    ),
    GetPage(
      name: AppRoutes.summary,
      page: () => const HikeSummaryView(),
      binding: HikeReplayBinding(),
    ),
  ];
}
