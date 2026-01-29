import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import 'glass_container.dart';

/// Place item widget for displaying a place with name and description
class PlaceItemWidget extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback? onDelete;

  const PlaceItemWidget({
    super.key,
    required this.name,
    required this.description,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyle.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
