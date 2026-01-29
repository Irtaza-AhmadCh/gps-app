import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../view_model/login_view_model.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header
              Text(AppStrings.login, style: AppTextStyle.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Welcome back',
                style: AppTextStyle.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Form
              CustomTextField(
                label: AppStrings.email,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
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

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: controller.forgotPassword,
                  child: Text(
                    AppStrings.forgotPassword,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),
              Obx(
                () => CustomButton(
                  text: AppStrings.login,
                  onTap: controller.login,
                  isLoading: controller.isLoading.value,
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: controller.goToSignup,
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: AppStrings.signup,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
