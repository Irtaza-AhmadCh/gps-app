import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackPositionType { top, bottom }

class AppSnackbar {
  AppSnackbar._(); // no instance

  // ==================== CORE SNACKBAR ====================

  static void _show({
    required String message,
    String? title,
    bool isError = false,

    Color? textColor,
    Color? backgroundColor,
    Color? iconColor,

    SnackPositionType position = SnackPositionType.top,

    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = false,
    EdgeInsets margin = const EdgeInsets.all(16),
    BorderRadius borderRadius =
    const BorderRadius.all(Radius.circular(12)),
  }) {
    Get.snackbar(
      title ?? (isError ? 'Error' : 'Success'),
      message,

      snackPosition: position == SnackPositionType.top
          ? SnackPosition.TOP
          : SnackPosition.BOTTOM,

      backgroundColor:
      backgroundColor ?? (isError ? Colors.red.shade600 : Colors.green.shade600),

      colorText: textColor ?? Colors.white,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: iconColor ?? Colors.white,
      ),

      duration: duration,
      margin: margin,
      borderRadius: borderRadius.topLeft.x,

      isDismissible: true,
      shouldIconPulse: false,
      showProgressIndicator: false,
      dismissDirection: DismissDirection.horizontal,
      mainButton: showCloseIcon
          ? TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          'CLOSE',
          style: TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }

  // ==================== PUBLIC HELPERS ====================

  /// ✅ Success Snackbar (Most Used)
  static void success({
    String? title,
    required String message,
  }) {
    _show(
      title: title ?? 'Success',
      message: message,
      isError: false,
    );
  }

  /// ❌ Error Snackbar (Most Used)
  static void error({
    String? title,
    required String message,
  }) {
    _show(
      title: title ?? 'Oops!',
      message: message,
      isError: true,
    );
  }
}
