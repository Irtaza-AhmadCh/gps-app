import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';

class OnboardingViewModel extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('OnboardingViewModel initialized');
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skip() {
    completeOnboarding();
  }

  void completeOnboarding() {
    LoggerService.logInfo('Onboarding completed, navigating to Login');
    Get.offNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
