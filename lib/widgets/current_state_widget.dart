import 'package:flutter/material.dart';
import '../services/sensor_service.dart';
import '../models/sensor_reading.dart';

class CurrentStateWidget extends StatelessWidget {
  final String hiveId;
  final SensorService sensorService;

  const CurrentStateWidget({
    super.key,
    required this.hiveId,
    required this.sensorService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SensorReading>>(
      stream: sensorService.getCurrentReadings(hiveId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        final readings = snapshot.data;
        if (readings == null || readings.isEmpty) {
          return const Center(
            child: Text('Aucune donnée disponible'),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'État actuel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...readings
                      .map((reading) => _buildReadingTile(context, reading)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadingTile(BuildContext context, SensorReading reading) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForType(reading.type),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLabelForType(reading.type),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${reading.value} ${reading.unit}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(reading.timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'weight':
        return Icons.scale;
      default:
        return Icons.sensors;
    }
  }

  String _getLabelForType(String type) {
    switch (type.toLowerCase()) {
      case 'temperature':
        return 'Température';
      case 'humidity':
        return 'Humidité';
      case 'weight':
        return 'Poids';
      default:
        return type;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }
}
