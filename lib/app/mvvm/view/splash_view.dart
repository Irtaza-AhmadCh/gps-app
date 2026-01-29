import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../view_model/splash_view_model.dart';
import 'package:flutter/services.dart';

class SplashView extends GetView<SplashViewModel> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded if not already by binding
    // GetView handles Get.find() internally
    final controller = Get.find<SplashViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.eerieBlack, Color(0xFF1E2A1F)],
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Placeholder
                GlassContainer(
                  width: 120,
                  height: 120,
                  borderRadius: 60,
                  child: Center(
                    child: Icon(
                      Icons.terrain,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  AppStrings.appName,
                  style: AppTextStyle.displaySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.splashTitle,
                  style: AppTextStyle.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
