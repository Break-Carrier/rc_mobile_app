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
      timeRange: _getTimeRangeFromFilter(timeFilter),
    );

    return _buildChartWithData(mockReadings);
  }

  Duration _getTimeRangeFromFilter(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.oneHour:
        return const Duration(hours: 1);
      case TimeFilter.sixHours:
        return const Duration(hours: 6);
      case TimeFilter.oneDay:
        return const Duration(days: 1);
      case TimeFilter.oneWeek:
        return const Duration(days: 7);
      case TimeFilter.oneMonth:
        return const Duration(days: 30);
      default:
        return const Duration(days: 1);
    }
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
            show: true, drawHorizontalLine: true, drawVerticalLine: false),
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
    );
  }

  FlTitlesData _buildTitlesData(List<SensorReading> readings) {
    return FlTitlesData(
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            return Text(
              DateFormat('HH:mm').format(date),
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
