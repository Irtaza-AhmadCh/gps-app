import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';

/// Large rounded button for primary tracking actions
/// Configurable color, icon, and label
class ControlButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLarge;

  const ControlButtonWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isLarge ? 28 : 20),
      label: Text(
        label,
        style: isLarge ? AppTextStyle.headlineSmall : AppTextStyle.button,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? AppColors.eerieBlack,
        padding: EdgeInsets.symmetric(
          vertical: isLarge ? 20 : 16,
          horizontal: isLarge ? 32 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLarge ? 24 : 16),
        ),
        elevation: 0,
      ),
    );
  }
}
