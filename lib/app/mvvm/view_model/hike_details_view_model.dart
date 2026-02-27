import 'package:get/get.dart';
import '../../repository/elevation_repository.dart';
import '../../services/logger_service.dart';
import '../../services/slope_service.dart';
import '../model/elevation_profile_data.dart';
import '../model/hike.dart';
import '../model/slope_segment.dart';
import 'add_hike_details_view_model.dart';

/// ViewModel for Hike Details View
/// Displays complete hike information including route, stats, places,
/// elevation profile, and slope gradient coloring.
class HikeDetailsViewModel extends GetxController {
  Hike? hike;
  final RxList<Place> places = <Place>[].obs;
  final RxList<String> images = <String>[].obs;

  // Elevation Profile
  final Rx<ElevationProfileData?> elevationProfile = Rx<ElevationProfileData?>(
    null,
  );
  final RxBool isLoadingElevation = false.obs;
  final RxBool elevationError = false.obs;

  // Slope Coloring
  final RxList<SlopeSegment> slopeSegments = <SlopeSegment>[].obs;
  final RxBool showSlopeColoring = false.obs;

  final ElevationRepository _elevationRepository = ElevationRepository();
  final SlopeService _slopeService = SlopeService.instance;

  @override
  void onInit() {
    super.onInit();
    hike = Get.arguments as Hike?;
    LoggerService.i(
      'HikeDetailsViewModel.onInit: Viewing hike - ${hike?.name}',
    );

    // Load data
    _loadMockPlaces();
    _loadMockImages();

    // Compute terrain data
    if (hike != null && hike!.points.isNotEmpty) {
      _computeSlopeSegments();
      _fetchElevationProfile();
    }
  }

  /// Toggle slope gradient coloring on the map
  void toggleSlopeColoring() {
    showSlopeColoring.value = !showSlopeColoring.value;
    LoggerService.i(
      'HikeDetailsViewModel.toggleSlopeColoring: ${showSlopeColoring.value}',
    );
  }

  /// Compute slope segments from the hike's track points (local, no API)
  void _computeSlopeSegments() {
    LoggerService.i(
      'HikeDetailsViewModel._computeSlopeSegments: computing for ${hike!.points.length} points',
    );
    final segments = _slopeService.generateSlopeSegments(hike!.points);
    slopeSegments.value = segments;
    LoggerService.i(
      'HikeDetailsViewModel._computeSlopeSegments: generated ${segments.length} segments',
    );
  }

  /// Fetch elevation profile (API with local fallback)
  Future<void> _fetchElevationProfile() async {
    LoggerService.i(
      'HikeDetailsViewModel._fetchElevationProfile: fetching for ${hike!.points.length} points',
    );
    isLoadingElevation.value = true;
    elevationError.value = false;

    try {
      final profile = await _elevationRepository.getElevationProfile(
        hike!.points,
      );
      elevationProfile.value = profile;
      LoggerService.i(
        'HikeDetailsViewModel._fetchElevationProfile: profile loaded: $profile',
      );
    } catch (e, stackTrace) {
      LoggerService.e(
        'HikeDetailsViewModel._fetchElevationProfile: failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      elevationError.value = true;
    } finally {
      isLoadingElevation.value = false;
    }
  }

  /// Retry fetching elevation profile
  void retryElevationProfile() {
    LoggerService.i('HikeDetailsViewModel.retryElevationProfile: retrying');
    if (hike != null && hike!.points.isNotEmpty) {
      _fetchElevationProfile();
    }
  }

  /// Load mock places for demonstration
  void _loadMockPlaces() {
    places.value = [
      Place(name: 'Summit Peak', description: 'Beautiful view from the top'),
      Place(name: 'Forest Trail', description: 'Dense forest with wildlife'),
      Place(name: 'Mountain Lake', description: 'Crystal clear mountain lake'),
    ];
  }

  /// Load mock images for demonstration
  void _loadMockImages() {
    images.value = [
      'https://images.pexels.com/photos/618833/pexels-photo-618833.jpeg',
      'https://images.pexels.com/photos/933054/pexels-photo-933054.jpeg',
      'https://images.pexels.com/photos/1365425/pexels-photo-1365425.jpeg',
    ];
  }
}
