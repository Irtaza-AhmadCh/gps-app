import 'package:flutter/material.dart';

/// App-wide color palette optimized for outdoor use and dark mode
class AppColors {
  AppColors._();

  // Primary Colors - High contrast for sunlight readability
  static const Color primary = Color(
    0xFF00C853,
  ); // Bright green for hiking theme
  static const Color primaryDark = Color(0xFF00A043);
  static const Color accent = Color(0xFF2196F3); // Blue for water/sky

  // Background Colors - Dark mode optimized
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);

  // Text Colors - High contrast
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF757575);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Map Colors
  static const Color routePolyline = Color(
    0xFFFF5722,
  ); // Orange-red for visibility
  static const Color startMarker = Color(0xFF4CAF50); // Green
  static const Color currentMarker = Color(0xFF2196F3); // Blue
  static const Color elevationGain = Color(0xFF4CAF50); // Green for uphill
  static const Color elevationLoss = Color(0xFFF44336); // Red for downhill

  // UI Elements
  static const Color cardBackground = Color(0xFF2C2C2C);
  static const Color divider = Color(0xFF424242);
  static const Color shadow = Color(0x40000000);

  // Map Placeholder (when offline and tiles unavailable)
  static const Color mapPlaceholder = Color(0xFF424242);
  static const Color mapPlaceholderText = Color(0xFF9E9E9E);
}
