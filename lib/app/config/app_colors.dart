import 'package:flutter/material.dart';

/// App-wide color palette optimized for outdoor use, dark mode, and glassmorphism
class AppColors {
  AppColors._();

  // Core Palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color platinum = Color(0xFFDBDBDB);
  static const Color dimGrey = Color(0xFF6B6B6B);
  static const Color eerieBlack = Color(0xFF191919);
  static const Color chartreuse = Color(0xFFD9FF42);

  // Semantic Colors
  static const Color primary = chartreuse;
  static const Color background = eerieBlack;
  static const Color surface = dimGrey;
  static const Color textPrimary = white;
  static const Color textSecondary = platinum;

  // Status Colors (Keeping existing functional colors where they make sense but tweaking for the theme)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);

  // Glassmorphism
  static Color glassBackground = dimGrey.withOpacity(0.3);
  static Color glassBorder = white.withOpacity(0.1);
  static Color glassShadow = Colors.black.withOpacity(0.2);

  // Map Colors (Specific requirements)
  static const Color routePolyline = chartreuse;
  static const Color startMarker = success;
  static const Color currentMarker = Color(0xFF2196F3);
  static const Color elevationGain = success;
  static const Color elevationLoss = error;

  // Placeholder
  static const Color mapPlaceholder = dimGrey;
  static const Color mapPlaceholderText = platinum;
}
