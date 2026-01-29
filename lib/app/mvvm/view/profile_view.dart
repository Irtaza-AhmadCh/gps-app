import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_button.dart';
import '../view_model/profile_view_model.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.profile, style: AppTextStyle.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/profile_placeholder.png',
                        ), // Will fail gracefully if not found
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.dimGrey,
                    ), // Fallback
                  ),
                  const SizedBox(height: 16),
                  Text('Hiker John', style: AppTextStyle.headlineMedium),
                  Text(
                    'john.hiker@email.com',
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings List
            _buildSettingItem(AppStrings.editProfile, Icons.edit_outlined),
            _buildSettingItem(AppStrings.privacy, Icons.shield_outlined),
            _buildSettingItem(AppStrings.about, Icons.info_outline),
            _buildSettingItem(AppStrings.terms, Icons.description_outlined),

            const SizedBox(height: 32),
            CustomButton(
              text: AppStrings.logout,
              onTap: controller.logout,
              isPrimary: false, // Outline button
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 12,
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyle.bodyLarge)),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
