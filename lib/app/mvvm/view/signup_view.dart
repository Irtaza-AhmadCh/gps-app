import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../view_model/signup_view_model.dart';

class SignupView extends GetView<SignupViewModel> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: controller.goToLogin,
                  ),
                  Text(AppStrings.signup, style: AppTextStyle.headlineLarge),
                ],
              ),
            ),

            // Progress Indicator
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(height: 4, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        color: controller.currentStep.value == 2
                            ? AppColors.primary
                            : AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Obx(
                  () => controller.currentStep.value == 1
                      ? _buildStep1()
                      : _buildStep2(),
                ),
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(24),
              child: Obx(
                () => CustomButton(
                  text: controller.currentStep.value == 1
                      ? AppStrings.continueText
                      : AppStrings.createAccount,
                  onTap: controller.nextStep,
                  isLoading: controller.isLoading.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.step1, style: AppTextStyle.labelMedium),
        const SizedBox(height: 8),
        Text('Create Identity', style: AppTextStyle.headlineMedium),
        const SizedBox(height: 24),

        CustomTextField(
          label: AppStrings.fullName,
          controller: controller.nameController,
          prefixIcon: const Icon(
            Icons.person_outline,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: AppStrings.email,
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => CustomTextField(
            label: AppStrings.password,
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: AppColors.textSecondary,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(AppStrings.passwordStrength, style: AppTextStyle.labelSmall),
        const SizedBox(height: 16),
        Obx(
          () => CustomTextField(
            label: AppStrings.confirmPassword,
            controller: controller.confirmPasswordController,
            obscureText: !controller.isPasswordVisible.value,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => controller.isTermsAccepted.toggle(),
          child: Row(
            children: [
              Obx(
                () => Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: controller.isTermsAccepted.value
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: controller.isTermsAccepted.value
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.eerieBlack,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(AppStrings.termsAndPrivacy, style: AppTextStyle.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: controller.previousStep,
          child: Text(
            'Back to Step 1',
            style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.step2, style: AppTextStyle.labelMedium),
        const SizedBox(height: 8),
        Text('Personalize Profile', style: AppTextStyle.headlineMedium),
        const SizedBox(height: 32),

        // Profile Pic Placeholder
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.textSecondary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: AppColors.eerieBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        CustomTextField(
          label: AppStrings.phoneNumber,
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(
            Icons.phone_outlined,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        Text(AppStrings.gender, style: AppTextStyle.labelMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Male', Icons.male)),
            const SizedBox(width: 16),
            Expanded(child: _buildGenderOption('Female', Icons.female)),
            const SizedBox(width: 16),
            Expanded(child: _buildGenderOption('Other', Icons.person_outline)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == label;
      return GestureDetector(
        onTap: () => controller.selectedGender.value = label,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: 12,
          color: isSelected ? AppColors.primary.withOpacity(0.2) : null,
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyle.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
