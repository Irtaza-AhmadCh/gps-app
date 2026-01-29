import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';
import '../model/hike.dart';

/// Place model for UI (mock data)
class Place {
  String name;
  String description;

  Place({required this.name, required this.description});
}

/// ViewModel for Add Hike Details screen
/// Allows user to add title, images (mock), and places visited
class AddHikeDetailsViewModel extends GetxController {
  Hike? hike;

  final titleController = TextEditingController();
  final RxList<String> mockImageUrls = <String>[].obs;
  final RxList<Place> places = <Place>[].obs;

  // Current place form
  final placeNameController = TextEditingController();
  final placeDescriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    hike = Get.arguments as Hike?;

    // Pre-fill with default title
    titleController.text = hike?.name ?? 'My Hike';

    LoggerService.logInfo(
      'AddHikeDetailsViewModel.onInit: Editing hike - ${hike?.name}',
    );
  }

  /// Add a mock image URL (UI only)
  void addMockImage() {
    // Add sample Pixabay/Pexels URLs for demo
    final sampleImages = [
      'https://images.pexels.com/photos/618833/pexels-photo-618833.jpeg',
      'https://images.pexels.com/photos/933054/pexels-photo-933054.jpeg',
      'https://images.pexels.com/photos/1365425/pexels-photo-1365425.jpeg',
      'https://images.pexels.com/photos/1624438/pexels-photo-1624438.jpeg',
    ];

    if (mockImageUrls.length < 4) {
      mockImageUrls.add(sampleImages[mockImageUrls.length]);
      LoggerService.logInfo(
        'AddHikeDetailsViewModel.addMockImage: Added mock image',
      );
    }
  }

  /// Remove image at index
  void removeImage(int index) {
    mockImageUrls.removeAt(index);
    LoggerService.logInfo(
      'AddHikeDetailsViewModel.removeImage: Removed image at $index',
    );
  }

  /// Add a place to the list
  void addPlace() {
    final name = placeNameController.text.trim();
    final description = placeDescriptionController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter a place name');
      return;
    }

    places.add(Place(name: name, description: description));
    placeNameController.clear();
    placeDescriptionController.clear();

    LoggerService.logInfo(
      'AddHikeDetailsViewModel.addPlace: Added place - $name',
    );
  }

  /// Remove place at index
  void removePlace(int index) {
    places.removeAt(index);
    LoggerService.logInfo(
      'AddHikeDetailsViewModel.removePlace: Removed place at $index',
    );
  }

  /// Save and navigate to hike details (UI only for now)
  void saveAndView() {
    final title = titleController.text.trim();

    LoggerService.logInfo(
      'AddHikeDetailsViewModel.saveAndView: Saving hike details - $title',
    );
    LoggerService.logInfo(
      'AddHikeDetailsViewModel.saveAndView: Images: ${mockImageUrls.length}, Places: ${places.length}',
    );

    // Navigate to hike details, removing all intermediate completion/add flows
    // Goal: Stack = Dashboard -> HikeDetails
    Get.offNamedUntil(
      AppRoutes.hikeDetails,
      (route) => route.settings.name == AppRoutes.dashboard,
      arguments: hike,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    placeNameController.dispose();
    placeDescriptionController.dispose();
    super.onClose();
  }
}
