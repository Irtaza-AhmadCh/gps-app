import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../view_model/bottom_bar_controller.dart';
import 'home_view.dart';
import 'live_tracking_view.dart';
import 'profile_view.dart';

/// BottomBarView
/// Main container with bottom navigation hosting Home, Record, and Profile
class BottomBarView extends GetView<BottomBarController> {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [HomeView(), LiveTrackingView(), ProfileView()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12.sp,
            unselectedFontSize: 12.sp,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24.sp),
                activeIcon: Icon(Icons.home, size: 24.sp),
                label: AppStrings.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.my_location_outlined, size: 24.sp),
                activeIcon: Icon(Icons.my_location, size: 24.sp),
                label: AppStrings.record,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24.sp),
                activeIcon: Icon(Icons.person, size: 24.sp),
                label: AppStrings.profileTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
