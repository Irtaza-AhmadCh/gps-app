import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gps/app/widgets/custom_button.dart';
import 'package:gps/app/widgets/glass_button.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/control_button_widget.dart';
import '../../widgets/image_grid_widget.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/map_widget.dart';
import '../../config/utils.dart';
import '../view_model/add_hike_details_view_model.dart';

import '../../widgets/app_bars.dart';

/// Add Hike Details View - Form to add title, images, and places
class AddHikeDetailsView extends GetView<AddHikeDetailsViewModel> {
  const AddHikeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.addDetails, showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Preview
            if (controller.hike != null)
              GlassContainer(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 200.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MapWidget(
                      points: controller.hike!.points,
                      showStartMarker: true,
                      showCurrentMarker: false,
                      isInteractive: false,
                      showMapSkinSwitcher: false,
                    ),
                  ),
                ),
              ),

            24.height,

            // Title input
            Text(AppStrings.hikeTitle, style: AppTextStyle.headlineSmall),
            12.height,
            CustomTextField(
              label: AppStrings.enterTitle,
              controller: controller.titleController,
              prefixIcon: const Icon(
                Icons.title,
                color: AppColors.textSecondary,
              ),
            ),

            32.height,

            // Images section
            Text(AppStrings.addImages, style: AppTextStyle.headlineSmall),
            12.height,
            ImageGridWidget(
              imageUrls: controller.mockImageUrls,
              onAddImage: controller.addMockImage,
              onRemoveImage: controller.removeImage,
            ),

            32.height,

            // Your Thoughts / Description
            Text(AppStrings.yourThoughts, style: AppTextStyle.headlineSmall),
            12.height,
            CustomTextField(
              label: "",
              controller: controller.descriptionController,
              maxLines: 4,
            ),

            24.height,

            // Tags
            Text(AppStrings.tags, style: AppTextStyle.headlineSmall),
            12.height,
            CustomTextField(
              label: AppStrings.enterTags,
              controller: controller.tagsController,
              prefixIcon: const Icon(Icons.tag, color: AppColors.textSecondary),
            ),

            32.height,

            // Action buttons
            CustomButton(
              text: AppStrings.saveAndView,

              onTap: controller.saveAndView,
            ),
            16.height,
            GlassButton(
              label: AppStrings.skipForNow,
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
