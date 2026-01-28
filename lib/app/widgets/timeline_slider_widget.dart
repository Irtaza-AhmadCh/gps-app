import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import '../config/utils.dart';

/// Timeline slider widget for hike replay
/// Allows scrubbing through hike points with play/pause controls
class TimelineSliderWidget extends StatelessWidget {
  final int currentIndex;
  final int maxIndex;
  final bool isPlaying;
  final Function(int) onChanged;
  final VoidCallback onPlayPause;
  final String currentLabel;

  const TimelineSliderWidget({
    super.key,
    required this.currentIndex,
    required this.maxIndex,
    required this.isPlaying,
    required this.onChanged,
    required this.onPlayPause,
    required this.currentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button and current label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Play/Pause button
              IconButton(
                onPressed: onPlayPause,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              // Current position label
              Text(
                currentLabel,
                style: AppTextStyle.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          8.height,

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.textSecondary.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: currentIndex.toDouble(),
              min: 0,
              max: maxIndex > 0 ? maxIndex.toDouble() : 1,
              divisions: maxIndex > 0 ? maxIndex : 1,
              onChanged: (value) => onChanged(value.toInt()),
            ),
          ),

          // Min/Max labels
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$maxIndex',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
