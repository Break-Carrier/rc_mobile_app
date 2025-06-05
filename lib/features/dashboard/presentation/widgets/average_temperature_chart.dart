import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../sensor/domain/entities/sensor_reading.dart';
import '../../../sensor/domain/entities/time_filter.dart';

class AverageTemperatureChart extends StatelessWidget {
  final List<SensorReading> readings;
  final TimeFilter currentFilter;
  final Function(TimeFilter) onTimeFilterChanged;
  final bool isLoading;

  const AverageTemperatureChart({
    super.key,
    required this.readings,
    required this.currentFilter,
    required this.onTimeFilterChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: isLoading
                  ? _buildLoadingIndicator()
                  : readings.isEmpty
                      ? _buildNoDataDisplay()
                      : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Température moyenne du rucher',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).primaryColor.withAlpha(50),
              width: 1,
            ),
          ),
          child: DropdownButton<TimeFilter>(
            value: currentFilter,
            onChanged: (TimeFilter? newValue) {
              if (newValue != null) {
                onTimeFilterChanged(newValue);
              }
            },
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor,
            ),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(10),
            items: TimeFilter.values.map((TimeFilter filter) {
              return DropdownMenuItem<TimeFilter>(
                value: filter,
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Chargement des données...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withAlpha(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.blue,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune donnée à afficher',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez de changer le filtre temporel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Obtenir les plages de valeurs pour l'échelle de l'axe Y
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    // Filtrer les lectures qui ont une température non-nulle
    final tempReadings = readings.where((r) => r.temperature != null).toList();

    if (tempReadings.isNotEmpty) {
      final temperatures =
          tempReadings.map((reading) => reading.temperature!).toList();

      final tempMin = temperatures.reduce((a, b) => a < b ? a : b);
      final tempMax = temperatures.reduce((a, b) => a > b ? a : b);

      minY = tempMin;
      maxY = tempMax;

      // Ajouter une marge de 10% à l'échelle
      final yRange = maxY - minY;
      minY = minY - (yRange * 0.1);
      maxY = maxY + (yRange * 0.1);
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                try {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('HH:mm').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                } catch (e) {
                  return const SizedBox();
                }
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: tempReadings
                .map((reading) => FlSpot(
                      reading.timestamp.millisecondsSinceEpoch.toDouble(),
                      reading.temperature!,
                    ))
                .toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: tempReadings.length < 10),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withValues(alpha: 0.15),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(
          enabled: true,
        ),
      ),
    );
  }
}
