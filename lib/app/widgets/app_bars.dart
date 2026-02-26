import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import 'glass_container.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? tintColor;
  final List<Widget>? actions;
  final Widget? titleWidget;
  final Widget? leadingWidget;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.onBackTap,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.tintColor,
    this.actions,
    this.titleWidget,
    this.leadingWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? Colors.transparent;
    final Color iconColor = tintColor ?? AppColors.white;

    return AppBar(
      elevation: elevation,
      backgroundColor: bgColor,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          if (leadingWidget != null)
            leadingWidget!.paddingOnly(left: 10, right: 6)
          else if (showBackButton)
            GestureDetector(
              onTap: onBackTap ?? () => Get.back(),
              child: GlassContainer(
                width: 36.sp,
                height: 36.sp,
                borderRadius: 40.sp,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ).paddingOnly(left: 10, right: 6),
          if (titleWidget != null)
            Expanded(child: titleWidget!)
          else if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTextStyle.headlineMedium.copyWith(color: iconColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }
}
