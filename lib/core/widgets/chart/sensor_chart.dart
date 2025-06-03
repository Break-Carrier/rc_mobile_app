import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../models/sensor_reading.dart';
import '../../../models/time_filter.dart';
import '../../../services/sensor_service.dart';
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
    final sensorService = Provider.of<SensorService>(context);
    final currentFilter = sensorService.currentTimeFilter;

    return ChartHeader(
      title: widget.showAverageTemperature
          ? 'Température moyenne du rucher'
          : 'Évolution des capteurs',
      currentFilter: currentFilter,
      onFilterChanged: (filter) => sensorService.setTimeFilter(filter),
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

    final sensorService = Provider.of<SensorService>(context);

    if (widget.showAverageTemperature && widget.apiaryId != null) {
      return _buildAverageTemperatureChart(sensorService, widget.apiaryId!);
    }

    return StreamBuilder<List<SensorReading>>(
      stream: sensorService.getSensorReadings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const ChartLoadingState();
        }

        if (snapshot.hasError) {
          return ChartErrorState(error: snapshot.error.toString());
        }

        final readings = snapshot.data ?? [];
        if (readings.isEmpty) {
          return _buildMockChart(); // Fallback to mock data if no real data
        }

        return _buildChartWithData(readings);
      },
    );
  }

  Widget _buildMockChart() {
    final sensorService = Provider.of<SensorService>(context);
    final timeFilter = sensorService.currentTimeFilter;

    final mockReadings = MockData.generateMockReadings(
      hiveId: widget.hiveId ?? 'mock_hive_01',
      timeRange: timeFilter.duration,
    );

    return _buildChartWithData(mockReadings);
  }

  Widget _buildAverageTemperatureChart(
      SensorService sensorService, String apiaryId) {
    return StreamBuilder<List<SensorReading>>(
      stream: sensorService.getAverageTemperatureForApiary(apiaryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const ChartLoadingState();
        }

        if (snapshot.hasError) {
          return ChartErrorState(error: snapshot.error.toString());
        }

        final readings = snapshot.data ?? [];
        if (readings.isEmpty) {
          return _buildMockChart(); // Fallback to mock data
        }

        return _buildChartWithData(readings);
      },
    );
  }

  Widget _buildChartWithData(List<SensorReading> readings) {
    if (readings.isEmpty) {
      return const ChartEmptyState();
    }

    // Séparer les lectures par type
    final tempReadings =
        readings.where((r) => r.type == 'temperature').toList();
    final humidityReadings =
        readings.where((r) => r.type == 'humidity').toList();

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
      spots: readings.map((reading) {
        return FlSpot(
          reading.timestamp.millisecondsSinceEpoch.toDouble(),
          reading.value,
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
      spots: readings.map((reading) {
        return FlSpot(
          reading.timestamp.millisecondsSinceEpoch.toDouble(),
          reading.value,
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
