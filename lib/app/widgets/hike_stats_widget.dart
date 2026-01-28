import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import '../config/utils.dart';

/// Reusable widget for displaying hike statistics
class HikeStatsWidget extends StatelessWidget {
  final double distance;
  final double elevationGain;
  final double elevationLoss;
  final Duration duration;
  final double? avgSpeed;
  final double? maxElevation;
  final double? minElevation;

  const HikeStatsWidget({
    super.key,
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.duration,
    this.avgSpeed,
    this.maxElevation,
    this.minElevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Primary stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Distance',
                value: Utils.formatDistance(distance),
                icon: Icons.straighten,
              ),
              _buildStatItem(
                label: 'Duration',
                value: Utils.formatDuration(duration),
                icon: Icons.timer,
              ),
              _buildStatItem(
                label: 'Gain',
                value: Utils.formatElevationSimple(elevationGain),
                icon: Icons.trending_up,
                valueColor: AppColors.elevationGain,
              ),
            ],
          ),

          // Secondary stats row (if provided)
          if (avgSpeed != null ||
              maxElevation != null ||
              minElevation != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (avgSpeed != null)
                  _buildStatItem(
                    label: 'Avg Speed',
                    value: Utils.formatSpeed(avgSpeed!),
                    icon: Icons.speed,
                  ),
                if (maxElevation != null)
                  _buildStatItem(
                    label: 'Max Elev',
                    value: Utils.formatElevationSimple(maxElevation!),
                    icon: Icons.arrow_upward,
                  ),
                if (minElevation != null)
                  _buildStatItem(
                    label: 'Min Elev',
                    value: Utils.formatElevationSimple(minElevation!),
                    icon: Icons.arrow_downward,
                  ),
              ],
            ),
          ],

          // Elevation loss (always show with gain)
          const SizedBox(height: 16),
          _buildStatItem(
            label: 'Elevation Loss',
            value: Utils.formatElevationSimple(elevationLoss),
            icon: Icons.trending_down,
            valueColor: AppColors.elevationLoss,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: valueColor ?? AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyle.statValue.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyle.statLabel),
      ],
    );
  }
}
