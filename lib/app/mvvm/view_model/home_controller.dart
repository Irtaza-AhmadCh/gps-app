import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../repository/hike_repository.dart';
import '../model/hike.dart';

/// Controller for Home View
/// Manages saved hikes list and GPS permission status
class HomeController extends GetxController {
  final HikeRepository _repository = HikeRepository();

  // Observable state
  final RxList<Hike> savedHikes = <Hike>[].obs;
  final RxBool hasGpsPermission = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLocationServiceEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.i('HomeController.onInit: Initializing HomeController');
    _checkPermissions();
    _loadHikes();
  }

  /// Check GPS permission status
  Future<void> _checkPermissions() async {
    LoggerService.i(
      'HomeController._checkPermissions: Checking location permissions and service status',
    );
    hasGpsPermission.value = await _repository.hasLocationPermission();
    isLocationServiceEnabled.value = await _repository
        .isLocationServiceEnabled();
    LoggerService.i(
      'HomeController._checkPermissions: hasGpsPermission: ${hasGpsPermission.value}, isLocationServiceEnabled: ${isLocationServiceEnabled.value}',
    );
  }

  /// Request GPS permission
  Future<void> requestPermission() async {
    LoggerService.i(
      'HomeController.requestPermission: Requesting location permission',
    );
    final granted = await _repository.requestLocationPermission();
    hasGpsPermission.value = granted;
    LoggerService.i(
      'HomeController.requestPermission: Permission granted: $granted',
    );

    if (!granted) {
      // Check if permanently denied
      final permanentlyDenied = await _repository.isPermissionDeniedForever();
      LoggerService.i(
        'HomeController.requestPermission: Permanently denied: $permanentlyDenied',
      );
      if (permanentlyDenied) {
        Get.snackbar(
          'Permission Required',
          'Please enable location permission in settings',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// Open app settings
  Future<void> openSettings() async {
    LoggerService.i('HomeController.openSettings: Opening app settings');
    await _repository.openSettings();
  }

  /// Load saved hikes from storage
  Future<void> _loadHikes() async {
    try {
      LoggerService.i('HomeController._loadHikes: Loading saved hikes');
      isLoading.value = true;
      savedHikes.value = await _repository.loadHikes();
      LoggerService.i(
        'HomeController._loadHikes: Loaded ${savedHikes.length} hikes',
      );
    } catch (e, stackTrace) {
      LoggerService.e(
        'HomeController._loadHikes: Failed to load hikes: $e',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to load hikes: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh hikes list
  Future<void> refreshHikes() async {
    await _loadHikes();
  }

  /// Delete a hike
  Future<void> deleteHike(String hikeId) async {
    try {
      LoggerService.i('HomeController.deleteHike: Deleting hike $hikeId');
      await _repository.deleteHike(hikeId);
      savedHikes.removeWhere((hike) => hike.id == hikeId);
      LoggerService.i('HomeController.deleteHike: Hike deleted successfully');
      Get.snackbar(
        'Success',
        'Hike deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      LoggerService.e(
        'HomeController.deleteHike: Failed to delete hike: $e',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Error',
        'Failed to delete hike: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate to tracking screen
  void startNewHike() {
    LoggerService.i(
      'HomeController.startNewHike: Navigating to tracking screen',
    );
    Get.toNamed('/tracking');
  }

  /// Navigate to hike summary
  void viewHikeSummary(Hike hike) {
    LoggerService.i(
      'HomeController.viewHikeSummary: Navigating to summary for hike ${hike.id}',
    );
    Get.toNamed('/summary', arguments: hike);
  }
}
