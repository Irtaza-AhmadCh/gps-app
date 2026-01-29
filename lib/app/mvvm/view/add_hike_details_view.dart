import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/control_button_widget.dart';
import '../../widgets/place_item_widget.dart';
import '../../widgets/image_grid_widget.dart';
import '../../widgets/custom_text_field.dart';
import '../view_model/add_hike_details_view_model.dart';

/// Add Hike Details View - Form to add title, images, and places
class AddHikeDetailsView extends GetView<AddHikeDetailsViewModel> {
  const AddHikeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.addDetails, style: AppTextStyle.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            Text(AppStrings.hikeTitle, style: AppTextStyle.headlineSmall),
            const SizedBox(height: 12),
            CustomTextField(
              label: AppStrings.enterTitle,
              controller: controller.titleController,
              prefixIcon: const Icon(
                Icons.title,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // Images section
            Text(AppStrings.addImages, style: AppTextStyle.headlineSmall),
            const SizedBox(height: 12),
            Obx(
              () => ImageGridWidget(
                imageUrls: controller.mockImageUrls,
                onAddImage: controller.addMockImage,
                onRemoveImage: controller.removeImage,
              ),
            ),

            const SizedBox(height: 32),

            // Places section
            Text(AppStrings.placesVisited, style: AppTextStyle.headlineSmall),
            const SizedBox(height: 12),

            // Add place form
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    label: AppStrings.placeName,
                    controller: controller.placeNameController,
                    prefixIcon: const Icon(
                      Icons.place,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: AppStrings.placeDescription,
                    controller: controller.placeDescriptionController,
                    maxLines: 3,
                    prefixIcon: const Icon(
                      Icons.description,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.addPlace,
                      icon: const Icon(Icons.add),
                      label: Text(AppStrings.addPlace),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.eerieBlack,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Places list
            Obx(() {
              if (controller.places.isEmpty) {
                return GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      AppStrings.noPlacesAdded,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: controller.places.asMap().entries.map((entry) {
                  final index = entry.key;
                  final place = entry.value;
                  return PlaceItemWidget(
                    name: place.name,
                    description: place.description,
                    onDelete: () => controller.removePlace(index),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 32),

            // Action buttons
            ControlButtonWidget(
              label: AppStrings.saveAndView,
              icon: Icons.check,
              onPressed: controller.saveAndView,
              isLarge: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: controller.saveAndView,
                child: Text(
                  AppStrings.skipForNow,
                  style: AppTextStyle.button.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
