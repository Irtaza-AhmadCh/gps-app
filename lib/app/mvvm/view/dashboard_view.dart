import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';
import '../../config/app_strings.dart';
import '../../widgets/glass_container.dart';
import '../view_model/dashboard_view_model.dart';

class DashboardView extends GetView<DashboardViewModel> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, Hiker', style: AppTextStyle.headlineMedium),
                      Text(
                        'Ready to explore?',
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: controller.goToProfile,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Start Hike Card (Hero)
              GestureDetector(
                onTap: controller.startHike,
                child: GlassContainer(
                  height: 200,
                  width: double.infinity,
                  color: AppColors.primary.withOpacity(0.2),
                  padding: const EdgeInsets.all(24),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.directions_walk,
                          size: 80,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppColors.eerieBlack,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppStrings.startHike,
                            style: AppTextStyle.displaySmall,
                          ),
                          Text(
                            'Record your activity & stats',
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // // GPS Status/
              // Text(AppStrings.gpsStatus, style: AppTextStyle.headlineSmall),
              // const SizedBox(height: 12),
              // GlassContainer(
              //   padding: const EdgeInsets.all(16),
              //   child: Row(
              //     children: [
              //       const Icon(Icons.satellite_alt, color: AppColors.success),
              //       const SizedBox(width: 16),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text('GPS Signal', style: AppTextStyle.bodyLarge),
              //           Text(
              //             'Strong • 12 Satellites',
              //             style: AppTextStyle.bodySmall.copyWith(
              //               color: AppColors.success,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 24),
              Text(
                AppStrings.recentActivity,
                style: AppTextStyle.headlineSmall,
              ),
              const SizedBox(height: 12),

              // Recent Activity List (Mock)
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 12,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.landscape,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Morning Hike',
                                style: AppTextStyle.bodyLarge,
                              ),
                              Text(
                                '5.2 km • 1h 20m',
                                style: AppTextStyle.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text('Today', style: AppTextStyle.labelSmall),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
