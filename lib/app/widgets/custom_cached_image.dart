import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'glass_container.dart';

/// Custom Cached Image Widget
/// Wraps Image.network with caching logic (if cache info is available or by default flutter cache)
/// and handles loading/error states consistently.
class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool useGlassContainer;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.useGlassContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: AppColors.surface,
          child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
        );
      },
    );

    if (borderRadius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    if (useGlassContainer) {
      return GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: borderRadius,
        child: image,
      );
    }

    return image;
  }
}
