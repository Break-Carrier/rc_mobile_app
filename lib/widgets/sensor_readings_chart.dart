import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/sensor_reading.dart';
import '../models/time_filter.dart';
import '../services/sensor_service.dart';

class SensorReadingsChart extends StatefulWidget {
  const SensorReadingsChart({super.key});

  @override
  State<SensorReadingsChart> createState() => _SensorReadingsChartState();
}

class _SensorReadingsChartState extends State<SensorReadingsChart> {
  bool _showTemperature = true;
  bool _showHumidity = true;

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);
    final currentFilter = sensorService.currentTimeFilter;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, sensorService, currentFilter),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: StreamBuilder<List<SensorReading>>(
                stream: sensorService.getSensorReadings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return _buildLoadingIndicator();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorDisplay(snapshot.error.toString());
                  }

                  final readings = snapshot.data ?? [];

                  if (readings.isEmpty) {
                    return _buildNoDataDisplay();
                  }

                  return _buildChart(readings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SensorService sensorService,
      TimeFilter currentFilter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Évolution des capteurs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
                sensorService.setTimeFilter(newValue);
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

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          color: Colors.red.withAlpha(26),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.withAlpha(77), width: 1),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _showTemperature = !_showTemperature;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _showTemperature
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Température',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Card(
          color: Colors.blue.withAlpha(26),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue.withAlpha(77), width: 1),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _showHumidity = !_showHumidity;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _showHumidity
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Humidité',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 300,
      child: Column(
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
      ),
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withAlpha(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataDisplay() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 20),
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
            child: Icon(
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

  Widget _buildChart(List<SensorReading> readings) {
    // Nous devons trier les lectures par ordre chronologique pour le graphique
    final sortedReadings = List<SensorReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: _getMaxY(sortedReadings),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final reading = sortedReadings[spot.x.toInt()];
                final formatter = DateFormat('HH:mm:ss');
                final time = formatter.format(reading.timestamp);

                String text = '';
                if (spot.barIndex == 0 && _showTemperature) {
                  text = '${reading.temperature.toStringAsFixed(1)}°C à $time';
                } else if (spot.barIndex == 1 && _showHumidity) {
                  text = '${reading.humidity.toStringAsFixed(1)}% à $time';
                }

                return LineTooltipItem(
                  text,
                  TextStyle(
                    color: spot.barIndex == 0 ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (_, __) {},
          handleBuiltInTouches: true,
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval:
              sortedReadings.length < 10 ? 1 : sortedReadings.length / 10,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getIntervalForReadings(sortedReadings),
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= sortedReadings.length) {
                  return const SizedBox();
                }
                final reading = sortedReadings[value.toInt()];
                final formatter = DateFormat('HH:mm');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    formatter.format(reading.timestamp),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        lineBarsData: [
          if (_showTemperature)
            LineChartBarData(
              spots: _getTemperatureSpots(sortedReadings),
              isCurved: true,
              barWidth: 3,
              color: Colors.red,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withAlpha(26),
              ),
            ),
          if (_showHumidity)
            LineChartBarData(
              spots: _getHumiditySpots(sortedReadings),
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withAlpha(26),
              ),
            ),
        ],
      ),
    );
  }

  List<FlSpot> _getTemperatureSpots(List<SensorReading> readings) {
    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      spots.add(FlSpot(i.toDouble(), readings[i].temperature));
    }
    return spots;
  }

  List<FlSpot> _getHumiditySpots(List<SensorReading> readings) {
    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      spots.add(FlSpot(i.toDouble(), readings[i].humidity));
    }
    return spots;
  }

  double _getMaxY(List<SensorReading> readings) {
    double maxTemperature = 0;
    double maxHumidity = 0;

    for (final reading in readings) {
      if (reading.temperature > maxTemperature) {
        maxTemperature = reading.temperature;
      }
      if (reading.humidity > maxHumidity) {
        maxHumidity = reading.humidity;
      }
    }

    // Prendre la valeur maximale entre température et humidité
    // et ajouter une marge de 10%
    return (maxTemperature > maxHumidity ? maxTemperature : maxHumidity) * 1.1;
  }

  double _getIntervalForReadings(List<SensorReading> readings) {
    if (readings.length <= 5) return 1;
    if (readings.length <= 20) return 2;
    if (readings.length <= 60) return 5;
    if (readings.length <= 120) return 10;
    return readings.length / 10;
  }
}
