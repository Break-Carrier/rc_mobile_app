import 'package:flutter/material.dart';
import '../widgets/sensor_readings_chart.dart';

class SensorReadingsScreen extends StatelessWidget {
  final String hiveId;

  const SensorReadingsScreen({
    super.key,
    required this.hiveId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectures des capteurs'),
      ),
      body: Column(
        children: [
          // Graphique des lectures
          const Expanded(
            child: SensorReadingsChart(),
          ),
          // Informations détaillées
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoCard(
                  context,
                  'Température',
                  '24.5°C',
                  Icons.thermostat,
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  context,
                  'Humidité',
                  '65%',
                  Icons.water_drop,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
