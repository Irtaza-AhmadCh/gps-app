import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';
import '../model/hike.dart';
import '../../repository/hike_repository.dart';

/// Place model for UI (mock data)
class Place {
  String name;
  String description;

  Place({required this.name, required this.description});
}

/// ViewModel for Add Hike Details screen
/// Allows user to add title, images (mock), and places visited
class AddHikeDetailsViewModel extends GetxController {
  final HikeRepository _hikeRepository = HikeRepository();
  Hike? hike;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController(); // New
  final tagsController = TextEditingController(); // New

  final RxList<String> mockImageUrls = <String>[].obs;
  final RxList<Place> places = <Place>[].obs;

  // Current place form
  final placeNameController = TextEditingController();
  final placeDescriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    hike = Get.arguments as Hike?;

    if (hike == null) {
      LoggerService.e('AddHikeDetailsViewModel.onInit: No hike provided!');
      Get.back(); // Should probably navigate to dashboard
      return;
    }

    // Pre-fill with default title
    titleController.text = hike?.name ?? 'My Hike';

    // Add some initial mock images if list is empty
    if (mockImageUrls.isEmpty) {
      addMockImage();
    }

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

  /// Save and navigate to hike details
  Future<void> saveAndView() async {
    if (hike == null) return;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final tagsString = tagsController.text.trim();
    final List<String> tags = tagsString.isNotEmpty
        ? tagsString.split(',').map((e) => e.trim()).toList()
        : <String>[];

    // Use first place as the main place if available
    final mainPlace = places.isNotEmpty ? places.first.name : null;

    LoggerService.logInfo(
      'AddHikeDetailsViewModel.saveAndView: Saving hike details - $title',
    );

    // Create updated hike object
    final updatedHike = hike!.copyWith(
      name: title.isNotEmpty ? title : hike!.name,
      place: mainPlace,
      description: description,
      tags: tags,
      imageUrls: List.from(mockImageUrls),
    );

    try {
      // Save using repository
      await _hikeRepository.saveHike(updatedHike);

      Get.snackbar('Success', 'Hike saved successfully');

      // Navigate to hike details, removing all intermediate completion/add flows
      // Goal: Stack = Dashboard -> HikeDetails
      Get.offNamedUntil(
        AppRoutes.hikeDetails,
        (route) => route.settings.name == AppRoutes.dashboard,
        arguments: updatedHike,
      );
    } catch (e) {
      LoggerService.e('AddHikeDetailsViewModel: Error saving hike: $e');
      Get.snackbar('Error', 'Failed to save hike');
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    placeNameController.dispose();
    placeDescriptionController.dispose();
    super.onClose();
  }
}
