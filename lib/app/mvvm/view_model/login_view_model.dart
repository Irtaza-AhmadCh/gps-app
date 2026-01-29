import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/logger_service.dart';
import '../../config/app_routes.dart';

class LoginViewModel extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerService.logInfo('LoginViewModel initialized');
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void login() async {
    LoggerService.logInfo('Attempting login');
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      LoggerService.logError('Login failed: Empty fields');
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock API
    isLoading.value = false;

    LoggerService.logInfo('Login successful');
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void goToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void forgotPassword() {
    // TODO: Implement forgot password
    LoggerService.logInfo('Forgot password clicked');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
