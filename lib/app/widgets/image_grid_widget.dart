import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'glass_container.dart';

/// Image grid widget for displaying mock image URLs
class ImageGridWidget extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback? onAddImage;
  final Function(int)? onRemoveImage;
  final int maxImages;

  const ImageGridWidget({
    super.key,
    required this.imageUrls,
    this.onAddImage,
    this.onRemoveImage,
    this.maxImages = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length + (imageUrls.length < maxImages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < imageUrls.length) {
          return _buildImageItem(imageUrls[index], index);
        } else {
          return _buildAddButton();
        }
      },
    );
  }

  Widget _buildImageItem(String url, int index) {
    return Stack(
      children: [
        GlassContainer(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surface,
                child: const Icon(
                  Icons.broken_image,
                  color: AppColors.textSecondary,
                ),
              ),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (onRemoveImage != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => onRemoveImage!(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddImage,
      child: GlassContainer(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 40),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
