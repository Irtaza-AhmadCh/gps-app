import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isLoading;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30), // Rounded pill shape
          border: isPrimary
              ? null
              : Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.eerieBlack,
                    ),
                  ),
                )
              : Text(
                  text,
                  style: AppTextStyle.button.copyWith(
                    color: isPrimary ? AppColors.eerieBlack : AppColors.primary,
                  ),
                ),
        ),
      ),
    );
  }
}
