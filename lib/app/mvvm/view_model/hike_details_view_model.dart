import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../model/hike.dart';
import 'add_hike_details_view_model.dart';

/// ViewModel for Hike Details View
/// Displays complete hike information including route, stats, and places
class HikeDetailsViewModel extends GetxController {
  Hike? hike;
  final RxList<Place> places = <Place>[].obs;
  final RxList<String> images = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    hike = Get.arguments as Hike?;
    LoggerService.logInfo(
      'HikeDetailsViewModel.onInit: Viewing hike - ${hike?.name}',
    );

    // Load mock data (for demo purposes)
    _loadMockPlaces();
    _loadMockImages();
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
