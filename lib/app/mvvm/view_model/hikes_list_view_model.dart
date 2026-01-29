import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../repository/hike_repository.dart';
import '../../config/app_routes.dart';
import '../model/hike.dart';

/// ViewModel for Hikes List View
/// Displays all saved hikes and allows navigation to tracking or details
class HikesListViewModel extends GetxController {
  final HikeRepository _repository = HikeRepository();

  final RxList<Hike> hikes = <Hike>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasGpsPermission = true.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('HikesListViewModel.onInit: Initializing');
    loadHikes();
    checkPermission();
  }

  /// Check GPS permission status
  Future<void> checkPermission() async {
    try {
      hasGpsPermission.value = await _repository.hasLocationPermission();
      LoggerService.logInfo(
        'HikesListViewModel.checkPermission: Permission status - ${hasGpsPermission.value}',
      );
    } catch (e) {
      LoggerService.logError(
        'HikesListViewModel.checkPermission: Error checking permission',
        error: e,
      );
    }
  }

  /// Request GPS permission
  Future<void> requestPermission() async {
    try {
      LoggerService.logInfo(
        'HikesListViewModel.requestPermission: Requesting permission',
      );
      final granted = await _repository.requestLocationPermission();
      hasGpsPermission.value = granted;
    } catch (e) {
      LoggerService.logError(
        'HikesListViewModel.requestPermission: Error requesting permission',
        error: e,
      );
    }
  }

  /// Load all saved hikes
  Future<void> loadHikes() async {
    try {
      isLoading.value = true;
      LoggerService.logInfo('HikesListViewModel.loadHikes: Loading hikes');

      final loadedHikes = await _repository.loadHikes();
      hikes.value = loadedHikes;

      LoggerService.logInfo(
        'HikesListViewModel.loadHikes: Loaded ${hikes.length} hikes',
      );
    } catch (e) {
      LoggerService.logError(
        'HikesListViewModel.loadHikes: Error loading hikes',
        error: e,
      );
      Get.snackbar('Error', 'Failed to load hikes');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh hikes list
  Future<void> refreshHikes() async {
    await loadHikes();
  }

  /// Navigate to live tracking to start new hike
  void startNewHike() {
    LoggerService.logInfo('HikesListViewModel.startNewHike: Starting new hike');
    Get.toNamed(AppRoutes.tracking);
  }

  /// Navigate to hike details
  void viewHikeDetails(Hike hike) {
    LoggerService.logInfo(
      'HikesListViewModel.viewHikeDetails: Viewing hike - ${hike.name}',
    );
    Get.toNamed(AppRoutes.hikeDetails, arguments: hike);
  }

  /// Delete a hike
  Future<void> deleteHike(String hikeId) async {
    try {
      LoggerService.logInfo(
        'HikesListViewModel.deleteHike: Deleting hike - $hikeId',
      );
      await _repository.deleteHike(hikeId);
      hikes.removeWhere((h) => h.id == hikeId);
      Get.snackbar('Deleted', 'Hike deleted successfully');
    } catch (e) {
      LoggerService.logError(
        'HikesListViewModel.deleteHike: Error deleting hike',
        error: e,
      );
      Get.snackbar('Error', 'Failed to delete hike');
    }
  }
}
