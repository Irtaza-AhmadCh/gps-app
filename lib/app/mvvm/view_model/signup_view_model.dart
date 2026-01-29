import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';

class SignupViewModel extends GetxController {
  // Step 1 Controls
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isTermsAccepted = false.obs;
  final RxBool isPasswordVisible = false.obs;

  // Step 2 Controls
  final RxString selectedGender = ''.obs;
  final phoneController = TextEditingController();

  // State
  final RxInt currentStep = 1.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('SignupViewModel initialized');
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void nextStep() {
    if (currentStep.value == 1) {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        Get.snackbar('Error', 'Please fill all fields');
        return;
      }
      if (!isTermsAccepted.value) {
        Get.snackbar('Error', 'Please accept terms');
        return;
      }
      currentStep.value = 2;
    } else {
      createAccount();
    }
  }

  void previousStep() {
    if (currentStep.value == 2) {
      currentStep.value = 1;
    }
  }

  void createAccount() async {
    LoggerService.logInfo('Creating account');
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock API
    isLoading.value = false;

    LoggerService.logInfo('Account created');
    Get.offNamed(AppRoutes.permission);
  }

  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
