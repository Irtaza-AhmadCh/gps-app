import 'package:get/get.dart';
import '../mvvm/view/splash_view.dart';
import '../mvvm/view_model/bindings/splash_binding.dart';
import '../mvvm/view/home_view.dart';
import '../mvvm/view/live_tracking_view.dart';
import '../mvvm/view/hike_summary_view.dart';
import '../mvvm/view/onboarding_view.dart';
import '../mvvm/view/login_view.dart';
import '../mvvm/view/signup_view.dart';
import '../mvvm/view/permission_view.dart';
import '../mvvm/view/dashboard_view.dart';
import '../mvvm/view/profile_view.dart';
import '../mvvm/view/hike_completion_view.dart';
import '../mvvm/view/add_hike_details_view.dart';
import '../mvvm/view/hikes_list_view.dart';
import '../mvvm/view/hike_details_view.dart';
import '../mvvm/view_model/bindings/home_binding.dart';
import '../mvvm/view_model/bindings/hike_tracking_binding.dart';
import '../mvvm/view_model/bindings/hike_replay_binding.dart';
import '../mvvm/view_model/bindings/onboarding_binding.dart';
import '../mvvm/view_model/bindings/login_binding.dart';
import '../mvvm/view_model/bindings/signup_binding.dart';
import '../mvvm/view_model/bindings/permission_binding.dart';
import '../mvvm/view_model/bindings/dashboard_binding.dart';
import '../mvvm/view_model/bindings/profile_binding.dart';
import '../mvvm/view_model/bindings/hike_completion_binding.dart';
import '../mvvm/view_model/bindings/add_hike_details_binding.dart';
import '../mvvm/view_model/bindings/hikes_list_binding.dart';
import '../mvvm/view_model/bindings/hike_details_binding.dart';
import 'app_routes.dart';

/// App pages configuration with GetX bindings
class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.permission,
      page: () => const PermissionView(),
      binding: PermissionBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    // Existing routes - keeping for backward compatibility or future cleanup
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
    // New routes for redesigned UI
    GetPage(
      name: AppRoutes.hikeCompletion,
      page: () => const HikeCompletionView(),
      binding: HikeCompletionBinding(),
    ),
    GetPage(
      name: AppRoutes.addHikeDetails,
      page: () => const AddHikeDetailsView(),
      binding: AddHikeDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.hikesList,
      page: () => const HikesListView(),
      binding: HikesListBinding(),
    ),
    GetPage(
      name: AppRoutes.hikeDetails,
      page: () => const HikeDetailsView(),
      binding: HikeDetailsBinding(),
    ),
  ];
}
