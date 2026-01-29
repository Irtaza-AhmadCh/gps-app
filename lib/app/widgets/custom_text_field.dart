import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import 'glass_container.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 12,
      opacity: 0.1,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyle.labelMedium,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}
