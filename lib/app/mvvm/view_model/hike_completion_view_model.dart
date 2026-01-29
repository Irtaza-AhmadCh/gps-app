import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';
import '../model/hike.dart';

/// ViewModel for Hike Completion screen
/// Displays celebration and summary stats after completing a hike
class HikeCompletionViewModel extends GetxController {
  Hike? hike;

  @override
  void onInit() {
    super.onInit();
    hike = Get.arguments as Hike?;
    LoggerService.logInfo(
      'HikeCompletionViewModel.onInit: Hike completed - ${hike?.name}',
    );
  }

  /// Navigate to Add Hike Details screen
  void goToAddDetails() {
    LoggerService.logInfo(
      'HikeCompletionViewModel.goToAddDetails: Navigating to add details',
    );
    Get.toNamed(AppRoutes.addHikeDetails, arguments: hike);
  }

  /// Skip details and go directly to hike details view
  void skipAndView() {
    LoggerService.logInfo(
      'HikeCompletionViewModel.skipAndView: Skipping details entry',
    );
    // Navigate to details, removing completion screen from stack
    // Goal: Stack = Dashboard -> HikeDetails
    Get.offNamedUntil(
      AppRoutes.hikeDetails,
      (route) => route.settings.name == AppRoutes.dashboard,
      arguments: hike,
    );
  }
}
