import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/utils.dart';

/// Reusable elevation chart widget using fl_chart
/// Displays elevation profile with touch interaction
class ElevationChartWidget extends StatelessWidget {
  final List<double>? elevations;
  final List<double>? distances; // meters
  final int? currentIndex;
  final Function(int)? onPointTapped;

  const ElevationChartWidget({
    super.key,
    required this.elevations,
    required this.distances,
    this.currentIndex,
    this.onPointTapped,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Safety checks
    if (elevations == null ||
        distances == null ||
        elevations!.isEmpty ||
        distances!.isEmpty ||
        elevations!.length != distances!.length) {
      return _buildEmptyState();
    }

    final safeElevations = elevations!;
    final safeDistances = distances!;

    // If only one point → duplicate it slightly so chart can render
    if (safeElevations.length == 1) {
      safeElevations.add(safeElevations.first);
      safeDistances.add(safeDistances.first + 1);
    }

    // Prepare spots
    final List<FlSpot> spots = List.generate(
      safeElevations.length,
          (i) => FlSpot(
        (safeDistances[i] / 1000),
        safeElevations[i],
      ),
    );

    // Safe min/max
    final minElevation = safeElevations.reduce((a, b) => a < b ? a : b);
    final maxElevation = safeElevations.reduce((a, b) => a > b ? a : b);

    double elevationRange = maxElevation - minElevation;

    // Prevent zero range crash
    if (elevationRange == 0) {
      elevationRange = 10; // fallback range
    }

    final yMin = (minElevation - elevationRange * 0.1);
    final yMax = (maxElevation + elevationRange * 0.1);

    final totalDistanceKm = safeDistances.last / 1000;
    final double xInterval = totalDistanceKm == 0 ? 1 : totalDistanceKm / 4;
    final double yInterval = elevationRange == 0 ? 1 : elevationRange / 4;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: totalDistanceKm == 0 ? 1 : totalDistanceKm,
        minY: yMin,
        maxY: yMax,

        gridData: FlGridData(
          show: true,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.dimGrey.withOpacity(0.3),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (_) => FlLine(
            color: AppColors.dimGrey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),

        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: totalDistanceKm > 0,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toStringAsFixed(1)}km',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}m',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.dimGrey),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
        ],

        // ✅ Safe touch handling
        lineTouchData: LineTouchData(
          enabled: onPointTapped != null,
          touchCallback: (event, response) {
            if (event is FlTapUpEvent &&
                response?.lineBarSpots != null &&
                response!.lineBarSpots!.isNotEmpty &&
                onPointTapped != null) {
              final spot = response.lineBarSpots!.first;

              final tappedDistance = spot.x * 1000;

              int closestIndex = 0;
              double minDiff = double.infinity;

              for (int i = 0; i < safeDistances.length; i++) {
                final diff = (safeDistances[i] - tappedDistance).abs();
                if (diff < minDiff) {
                  minDiff = diff;
                  closestIndex = i;
                }
              }

              onPointTapped!(closestIndex);
            }
          },
        ),

        // ✅ Safe vertical indicator
        extraLinesData: (currentIndex != null &&
            currentIndex! >= 0 &&
            currentIndex! < safeDistances.length)
            ? ExtraLinesData(
          verticalLines: [
            VerticalLine(
              x: safeDistances[currentIndex!] / 1000,
              color: AppColors.elevationGain,
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
          ],
        )
            : ExtraLinesData(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No elevation data',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}