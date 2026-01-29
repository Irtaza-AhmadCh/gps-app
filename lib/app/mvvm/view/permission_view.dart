import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_button.dart';
import '../view_model/permission_view_model.dart';

class PermissionView extends GetView<PermissionViewModel> {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassContainer(
                width: 160,
                height: 160,
                borderRadius: 80,
                color: AppColors.primary.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              Text(
                AppStrings.enableLocation,
                style: AppTextStyle.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Text(
                  AppStrings.permissionExplanation,
                  style: AppTextStyle.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              Obx(
                () => CustomButton(
                  text: AppStrings.enableLocation,
                  onTap: controller.requestLocationPermission,
                  isLoading: controller.isLoading.value,
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'You can change this anytime in settings.',
                style: AppTextStyle.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
