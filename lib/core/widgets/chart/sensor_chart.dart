import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../features/sensor/domain/entities/sensor_reading.dart';
import '../../../features/sensor/domain/entities/time_filter.dart';
import '../../factories/service_factory.dart';
import '../../constants/mock_data.dart';
import 'chart_header.dart';
import 'chart_legend.dart';
import 'chart_states.dart';

class SensorChart extends StatefulWidget {
  final List<SensorReading>? readings;
  final String? apiaryId;
  final String? hiveId;
  final bool showAverageTemperature;
  final bool useMockDataInDev;

  const SensorChart({
    super.key,
    this.readings,
    this.apiaryId,
    this.hiveId,
    this.showAverageTemperature = false,
    this.useMockDataInDev = true,
  });

  @override
  State<SensorChart> createState() => _SensorChartState();
}

class _SensorChartState extends State<SensorChart> {
  bool _showTemperature = true;
  bool _showHumidity = true;
  TimeFilter _selectedFilter = TimeFilter.oneHour;
  late final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            ChartLegend(
              showTemperature: _showTemperature,
              showHumidity: _showHumidity,
              onTemperatureToggle: (value) =>
                  setState(() => _showTemperature = value),
              onHumidityToggle: (value) =>
                  setState(() => _showHumidity = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildChartContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ChartHeader(
      selectedFilter: _selectedFilter,
      onFilterChanged: (filter) {
        setState(() {
          _selectedFilter = filter;
        });
      },
    );
  }

  Widget _buildChartContent() {
    // En mode développement, utiliser des données mockées si demandé
    if (widget.useMockDataInDev && (widget.readings?.isEmpty ?? true)) {
      return _buildMockChart();
    }

    if (widget.readings != null) {
      return _buildChartWithData(widget.readings!);
    }

    // Pour l'instant, utiliser des données mock
    return _buildMockChart();
  }

  Widget _buildMockChart() {
    // Utiliser les données mockées du MockData
    final mockReadings = MockData.getReadingsForHive(
      widget.hiveId ?? 'hive_1',
    );

    return _buildChartWithData(mockReadings);
  }

  Widget _buildChartWithData(List<SensorReading> readings) {
    if (readings.isEmpty) {
      return const ChartEmptyState();
    }

    // Séparer les lectures par type de données (temperature, humidity)
    final tempReadings = readings.where((r) => r.temperature != null).toList();
    final humidityReadings = readings.where((r) => r.humidity != null).toList();

    // Créer les données pour le graphique
    final List<LineChartBarData> lineBarsData = [];

    if (_showTemperature && tempReadings.isNotEmpty) {
      lineBarsData.add(_createTemperatureLine(tempReadings));
    }

    if (_showHumidity && humidityReadings.isNotEmpty) {
      lineBarsData.add(_createHumidityLine(humidityReadings));
    }

    if (lineBarsData.isEmpty) {
      return const ChartEmptyState(
          message: 'Aucun type de données sélectionné');
    }

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        titlesData: _buildTitlesData(readings),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                final isTemp = spot.barIndex == 0 && _showTemperature;
                final unit = isTemp ? '°C' : '%';
                final type = isTemp ? 'Temp' : 'Hum';

                return LineTooltipItem(
                  '$type: ${spot.y.toStringAsFixed(1)}$unit\n${DateFormat('HH:mm').format(date)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  LineChartBarData _createTemperatureLine(List<SensorReading> readings) {
    return LineChartBarData(
      spots: readings
          .where((reading) => reading.temperature != null)
          .map((reading) {
        return FlSpot(
          reading.timestamp.millisecondsSinceEpoch.toDouble(),
          reading.temperature!,
        );
      }).toList(),
      isCurved: true,
      color: Colors.red,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.red.withValues(alpha: 0.1),
      ),
    );
  }

  LineChartBarData _createHumidityLine(List<SensorReading> readings) {
    return LineChartBarData(
      spots:
          readings.where((reading) => reading.humidity != null).map((reading) {
        return FlSpot(
          reading.timestamp.millisecondsSinceEpoch.toDouble(),
          reading.humidity!,
        );
      }).toList(),
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withValues(alpha: 0.1),
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<SensorReading> readings) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(0),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _calculateTimeInterval(readings),
          getTitlesWidget: (value, meta) {
            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            return Text(
              DateFormat('HH:mm').format(date),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  double? _calculateTimeInterval(List<SensorReading> readings) {
    if (readings.length < 2) return null;

    final span = readings.last.timestamp.millisecondsSinceEpoch -
        readings.first.timestamp.millisecondsSinceEpoch;

    // Adapter l'intervalle selon la plage de temps
    if (span < Duration.millisecondsPerHour * 2) {
      return Duration.millisecondsPerMinute * 15.0; // 15 min
    } else if (span < Duration.millisecondsPerDay) {
      return Duration.millisecondsPerHour * 1.0; // 1 heure
    } else {
      return Duration.millisecondsPerHour * 6.0; // 6 heures
    }
  }
}
