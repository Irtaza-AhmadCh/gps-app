import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_button.dart';
import '../view_model/onboarding_view_model.dart';

class OnboardingView extends GetView<OnboardingViewModel> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient (consistent with theme)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.eerieBlack, AppColors.background],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    children: [
                      _buildPage(
                        title: AppStrings.onboarding1Title,
                        desc: AppStrings.onboarding1Desc,
                        icon: Icons.map,
                      ),
                      _buildPage(
                        title: AppStrings.onboarding2Title,
                        desc: AppStrings.onboarding2Desc,
                        icon: Icons.shield_moon,
                      ),
                      _buildPage(
                        title: AppStrings.onboarding3Title,
                        desc: AppStrings.onboarding3Desc,
                        icon: Icons.people,
                      ),
                    ],
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Indicators
                      _buildIndicators(),
                      const SizedBox(height: 32),

                      // Buttons
                      Obx(
                        () => CustomButton(
                          text: controller.currentPage.value == 2
                              ? AppStrings.getStarted
                              : AppStrings.continueText,
                          onTap: controller.next,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => controller.currentPage.value == 2
                            ? const SizedBox(
                                height: 18,
                              ) // Spacer to match height
                            : GestureDetector(
                                onTap: controller.skip,
                                child: Text(
                                  AppStrings.skip,
                                  style: AppTextStyle.button.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            width: 200,
            height: 200,
            borderRadius: 100,
            color: AppColors.primary.withOpacity(0.1),
            child: Center(
              child: Icon(icon, size: 80, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 48),
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTextStyle.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  desc,
                  style: AppTextStyle.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.currentPage.value == index
                  ? AppColors.primary
                  : AppColors.dimGrey,
            ),
          );
        }),
      ),
    );
  }
}
