import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/utils.dart';

/// Reusable elevation chart widget using fl_chart
/// Displays elevation profile with touch interaction
class ElevationChartWidget extends StatelessWidget {
  final List<double> elevations;
  final List<double> distances; // Cumulative distances in meters
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
    if (elevations.isEmpty || distances.isEmpty) {
      return Center(
        child: Text(
          'No elevation data',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Prepare data points
    final List<FlSpot> spots = [];
    for (int i = 0; i < elevations.length; i++) {
      final distanceKm = distances[i] / 1000; // Convert to km
      spots.add(FlSpot(distanceKm, elevations[i]));
    }

    // Find min/max for Y axis
    final minElevation = elevations.reduce((a, b) => a < b ? a : b);
    final maxElevation = elevations.reduce((a, b) => a > b ? a : b);
    final elevationRange = maxElevation - minElevation;
    final yMin = (minElevation - elevationRange * 0.1).floorToDouble();
    final yMax = (maxElevation + elevationRange * 0.1).ceilToDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: elevationRange / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.divider.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.divider.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (distances.last / 1000) / 4, // 4 labels
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
              reservedSize: 50,
              interval: elevationRange / 4,
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
          border: Border.all(color: AppColors.divider),
        ),
        minX: 0,
        maxX: distances.last / 1000,
        minY: yMin,
        maxY: yMax,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: onPointTapped != null,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (event is FlTapUpEvent &&
                response != null &&
                onPointTapped != null) {
              final spot = response.lineBarSpots?.first;
              if (spot != null) {
                // Find closest index
                final tappedDistance = spot.x * 1000; // Convert back to meters
                int closestIndex = 0;
                double minDiff = double.infinity;
                for (int i = 0; i < distances.length; i++) {
                  final diff = (distances[i] - tappedDistance).abs();
                  if (diff < minDiff) {
                    minDiff = diff;
                    closestIndex = i;
                  }
                }
                onPointTapped!(closestIndex);
              }
            }
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}m\n${spot.x.toStringAsFixed(2)}km',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: currentIndex != null
            ? ExtraLinesData(
                verticalLines: [
                  VerticalLine(
                    x: distances[currentIndex!] / 1000,
                    color: AppColors.accent,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
