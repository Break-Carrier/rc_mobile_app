import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/sensor_reading.dart';
import '../models/time_filter.dart';
import '../services/sensor_service.dart';

class SensorReadingsChart extends StatefulWidget {
  final List<SensorReading>? readings;
  final String? apiaryId;
  final bool showAverageTemperature;

  const SensorReadingsChart({
    super.key,
    this.readings,
    this.apiaryId,
    this.showAverageTemperature = false,
  });

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
              child: widget.readings != null
                  ? _buildChartWithData(widget.readings!)
                  : widget.showAverageTemperature && widget.apiaryId != null
                      ? _buildAverageTemperatureChart(
                          sensorService, widget.apiaryId!)
                      : StreamBuilder<List<SensorReading>>(
                          stream: sensorService.getSensorReadings(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return _buildLoadingIndicator();
                            }

                            if (snapshot.hasError) {
                              return _buildErrorDisplay(
                                  snapshot.error.toString());
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

  Widget _buildAverageTemperatureChart(
      SensorService sensorService, String apiaryId) {
    return StreamBuilder<List<SensorReading>>(
      stream: sensorService.getAverageTemperatureForApiary(apiaryId),
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

        return _buildChartWithData(readings);
      },
    );
  }

  Widget _buildHeader(BuildContext context, SensorService sensorService,
      TimeFilter currentFilter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            widget.showAverageTemperature
                ? 'Température moyenne du rucher'
                : 'Évolution des capteurs',
            style: const TextStyle(
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
    final temperatureReadings = readings
        .where((reading) => reading.type.toLowerCase() == 'temperature')
        .toList();
    final humidityReadings = readings
        .where((reading) => reading.type.toLowerCase() == 'humidity')
        .toList();

    if (widget.showAverageTemperature) {
      // Si c'est la vue de température moyenne, désactiver l'humidité
      _showHumidity = false;
    }

    // Si aucune donnée n'est disponible ou si aucun type n'est sélectionné
    if ((temperatureReadings.isEmpty || !_showTemperature) &&
        (humidityReadings.isEmpty || !_showHumidity)) {
      return _buildNoDataDisplay();
    }

    // Obtenir les plages de valeurs pour l'échelle de l'axe Y
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    if (_showTemperature && temperatureReadings.isNotEmpty) {
      final tempMin = temperatureReadings
          .map((reading) => reading.value)
          .reduce((a, b) => a < b ? a : b);
      final tempMax = temperatureReadings
          .map((reading) => reading.value)
          .reduce((a, b) => a > b ? a : b);
      minY = tempMin < minY ? tempMin : minY;
      maxY = tempMax > maxY ? tempMax : maxY;
    }

    if (_showHumidity && humidityReadings.isNotEmpty) {
      final humMin = humidityReadings
          .map((reading) => reading.value)
          .reduce((a, b) => a < b ? a : b);
      final humMax = humidityReadings
          .map((reading) => reading.value)
          .reduce((a, b) => a > b ? a : b);
      minY = humMin < minY ? humMin : minY;
      maxY = humMax > maxY ? humMax : maxY;
    }

    // Ajouter une marge de 10% à l'échelle
    final yRange = maxY - minY;
    minY = minY - (yRange * 0.1);
    maxY = maxY + (yRange * 0.1);

    // Ajuster minY pour qu'il ne soit jamais négatif pour l'humidité
    if (_showHumidity && !_showTemperature) {
      minY = minY < 0 ? 0 : minY;
    }

    // Déterminer la plage des timestamps pour l'axe X
    final timestamps = [...temperatureReadings, ...humidityReadings]
        .map((reading) => reading.timestamp.millisecondsSinceEpoch)
        .toList();
    timestamps.sort();
    final minX = timestamps.isNotEmpty ? timestamps.first.toDouble() : 0;
    final maxX = timestamps.isNotEmpty ? timestamps.last.toDouble() : 1;

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
          if (_showTemperature && temperatureReadings.isNotEmpty)
            LineChartBarData(
              spots: temperatureReadings
                  .map((reading) => FlSpot(
                        reading.timestamp.millisecondsSinceEpoch.toDouble(),
                        reading.value,
                      ))
                  .toList(),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: FlDotData(show: temperatureReadings.length < 10),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.15),
              ),
            ),
          if (_showHumidity && humidityReadings.isNotEmpty)
            LineChartBarData(
              spots: humidityReadings
                  .map((reading) => FlSpot(
                        reading.timestamp.millisecondsSinceEpoch.toDouble(),
                        reading.value,
                      ))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: humidityReadings.length < 10),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.15),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
        ),
      ),
    );
  }

  Widget _buildChartWithData(List<SensorReading> readings) {
    final temperatureReadings = readings
        .where((reading) => reading.type.toLowerCase() == 'temperature')
        .toList();
    final humidityReadings = readings
        .where((reading) => reading.type.toLowerCase() == 'humidity')
        .toList();

    if (widget.showAverageTemperature) {
      // For average temperature, only show temperature data
      return _buildChart(readings);
    }

    if (temperatureReadings.isEmpty && humidityReadings.isEmpty) {
      return _buildNoDataDisplay();
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
          if (_showTemperature && temperatureReadings.isNotEmpty)
            LineChartBarData(
              spots: temperatureReadings
                  .map((reading) => FlSpot(
                        reading.timestamp.millisecondsSinceEpoch.toDouble(),
                        reading.value,
                      ))
                  .toList(),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: FlDotData(show: temperatureReadings.length < 10),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.15),
              ),
            ),
          if (_showHumidity && humidityReadings.isNotEmpty)
            LineChartBarData(
              spots: humidityReadings
                  .map((reading) => FlSpot(
                        reading.timestamp.millisecondsSinceEpoch.toDouble(),
                        reading.value,
                      ))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: humidityReadings.length < 10),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.15),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
        ),
      ),
    );
  }
}
