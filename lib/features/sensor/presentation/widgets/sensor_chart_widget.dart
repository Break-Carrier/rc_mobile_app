import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sensor_reading.dart';

/// Widget pour afficher un graphique des données de capteurs sur 7 heures
class SensorChartWidget extends StatelessWidget {
  final List<SensorReading> readings;
  final String title;
  final bool showTemperature;
  final bool showHumidity;

  const SensorChartWidget({
    super.key,
    required this.readings,
    this.title = 'Données des capteurs (7h)',
    this.showTemperature = true,
    this.showHumidity = true,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(context),
            ),
            const SizedBox(height: 12),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.show_chart,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        Text(
          '7 dernières heures',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= readings.length) return const SizedBox();
                final reading = readings[value.toInt()];
                return Text(
                  DateFormat('HH:mm').format(reading.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.3),
          ),
        ),
        minX: 0,
        maxX: (readings.length - 1).toDouble(),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: _buildLineBarsData(context),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final reading = readings[spot.x.toInt()];
                return LineTooltipItem(
                  '${DateFormat('HH:mm').format(reading.timestamp)}\n'
                  '${showTemperature ? 'Temp: ${reading.temperature.toStringAsFixed(1)}°C' : ''}'
                  '${showTemperature && showHumidity ? '\n' : ''}'
                  '${showHumidity ? 'Humi: ${reading.humidity.toStringAsFixed(1)}%' : ''}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData(BuildContext context) {
    final List<LineChartBarData> lineBarsData = [];

    if (showTemperature) {
      lineBarsData.add(
        LineChartBarData(
          spots: readings.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.temperature);
          }).toList(),
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.withValues(alpha: 0.1),
          ),
        ),
      );
    }

    if (showHumidity) {
      lineBarsData.add(
        LineChartBarData(
          spots: readings.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.humidity);
          }).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.1),
          ),
        ),
      );
    }

    return lineBarsData;
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showTemperature) ...[
          _buildLegendItem(
            context,
            color: Colors.red,
            label: 'Température (°C)',
          ),
          if (showHumidity) const SizedBox(width: 24),
        ],
        if (showHumidity)
          _buildLegendItem(
            context,
            color: Colors.blue,
            label: 'Humidité (%)',
          ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune donnée historique',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les données de capteurs sur 7 heures ne sont pas encore disponibles.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _getMinY() {
    if (readings.isEmpty) return 0;

    double minValue = double.infinity;
    for (final reading in readings) {
      if (showTemperature)
        minValue =
            minValue < reading.temperature ? minValue : reading.temperature;
      if (showHumidity)
        minValue = minValue < reading.humidity ? minValue : reading.humidity;
    }

    // Ajouter une marge de 5% en bas
    return (minValue * 0.95).floorToDouble();
  }

  double _getMaxY() {
    if (readings.isEmpty) return 100;

    double maxValue = 0;
    for (final reading in readings) {
      if (showTemperature)
        maxValue =
            maxValue > reading.temperature ? maxValue : reading.temperature;
      if (showHumidity)
        maxValue = maxValue > reading.humidity ? maxValue : reading.humidity;
    }

    // Ajouter une marge de 5% en haut
    return (maxValue * 1.05).ceilToDouble();
  }
}
