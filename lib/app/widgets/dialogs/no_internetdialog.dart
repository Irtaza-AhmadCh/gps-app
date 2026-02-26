import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_colors.dart';

class NoInternetDialog {
  static void show({
    String? title,
    String? message,
    String? closeText,
    VoidCallback? onClose,
    bool barrierDismissible = true,
    Color primaryColor = AppColors.primary,
  }) {
    Get.dialog(
      _AnimatedNoInternetDialog(
        title: title,
        message: message,
        closeText: closeText,
        onClose: onClose,
        barrierDismissible: barrierDismissible,
        primaryColor: primaryColor,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.background.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOutSine,
    );
  }
}

class _AnimatedNoInternetDialog extends StatefulWidget {
  final String? title;
  final String? message;
  final String? closeText;
  final VoidCallback? onClose;
  final bool barrierDismissible;
  final Color primaryColor;

  const _AnimatedNoInternetDialog({
    this.title,
    this.message,
    this.closeText,
    this.onClose,
    required this.barrierDismissible,
    required this.primaryColor,
  });

  @override
  _AnimatedNoInternetDialogState createState() =>
      _AnimatedNoInternetDialogState();
}

class _AnimatedNoInternetDialogState extends State<_AnimatedNoInternetDialog>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;
  Animation<double>? _iconScaleAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutSine),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
      ),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOutSine),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller!,
            curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null ||
        _scaleAnimation == null ||
        _fadeAnimation == null ||
        _iconScaleAnimation == null ||
        _slideAnimation == null ||
        _pulseAnimation == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: ScaleTransition(
        scale: _scaleAnimation!,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.background.withOpacity(0.1),
                  blurRadius: 16.0,
                  offset: const Offset(0, 8),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 28.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon with Sleek Scale
                  ScaleTransition(
                    scale: _iconScaleAnimation!,
                    child: Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 32.0,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Title with Slide Animation
                  SlideTransition(
                    position: _slideAnimation!,
                    child: Text(
                      widget.title ?? "No Internet Connection",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // Message with Slide Animation
                  SlideTransition(
                    position: _slideAnimation!,
                    child: Text(
                      widget.message ??
                          "Please check your connection and try again.",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                        height: 1.5,
                        letterSpacing: 0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Animated Close Button with Subtle Pulse
                  ScaleTransition(
                    scale: _pulseAnimation!,
                    child: Container(
                      width: double.infinity,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: widget.primaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.2),
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          widget.onClose?.call();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          widget.closeText ?? "Close",
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
