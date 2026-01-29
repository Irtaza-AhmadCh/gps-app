import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../config/utils.dart';
import '../../widgets/control_button_widget.dart';
import '../../widgets/stat_card_widget.dart';
import '../view_model/hike_completion_view_model.dart';

/// Hike Completion View - Celebration screen after completing a hike
class HikeCompletionView extends GetView<HikeCompletionViewModel> {
  const HikeCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    final hike = controller.hike;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                AppStrings.hikeCompleted,
                style: AppTextStyle.displaySmall.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.completionMessage,
                style: AppTextStyle.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Stats summary
              if (hike != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: StatCardWidget(
                        icon: Icons.straighten,
                        value: Utils.formatDistance(hike.totalDistance),
                        label: AppStrings.distance,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCardWidget(
                        icon: Icons.timer,
                        value: Utils.formatDuration(hike.duration),
                        label: AppStrings.duration,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCardWidget(
                        icon: Icons.trending_up,
                        value: Utils.formatElevationSimple(hike.elevationGain),
                        label: AppStrings.elevationGain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCardWidget(
                        icon: Icons.speed,
                        value: Utils.formatSpeed(hike.averageSpeed),
                        label: AppStrings.avgSpeed,
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // Action buttons
              ControlButtonWidget(
                label: AppStrings.addDetails,
                icon: Icons.edit,
                onPressed: controller.goToAddDetails,
                isLarge: true,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.skipAndView,
                child: Text(
                  AppStrings.skipForNow,
                  style: AppTextStyle.button.copyWith(
                    color: AppColors.textSecondary,
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
