import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/bloc/readings_bloc.dart';
import '../../domain/bloc/readings_event.dart';
import '../../domain/bloc/readings_state.dart';
import '../../domain/entities/sensor_reading.dart';

/// Écran d'affichage des lectures de capteurs
class SensorReadingsScreen extends StatefulWidget {
  final String hiveId;

  const SensorReadingsScreen({
    super.key,
    required this.hiveId,
  });

  @override
  State<SensorReadingsScreen> createState() => _SensorReadingsScreenState();
}

class _SensorReadingsScreenState extends State<SensorReadingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReadingsBloc>().add(SubscribeToHiveReadings(widget.hiveId));
  }

  @override
  void dispose() {
    context.read<ReadingsBloc>().add(CancelSubscriptions());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectures des capteurs'),
      ),
      body: BlocBuilder<ReadingsBloc, ReadingsState>(
        builder: (context, state) {
          if (state is ReadingsInitial) {
            return const Center(
              child: Text('Chargement des lectures...'),
            );
          } else if (state is ReadingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ReadingsLoaded) {
            return _buildReadingsList(state.readings);
          } else if (state is ReadingsError) {
            return Center(
              child: Text('Erreur: ${state.message}'),
            );
          } else {
            return const Center(
              child: Text('État inconnu'),
            );
          }
        },
      ),
    );
  }

  Widget _buildReadingsList(List<SensorReading> readings) {
    if (readings.isEmpty) {
      return const Center(
        child: Text('Aucune lecture disponible'),
      );
    }

    // Grouper les lectures par type
    final Map<String, List<SensorReading>> groupedReadings = {};
    for (final reading in readings) {
      if (!groupedReadings.containsKey(reading.type)) {
        groupedReadings[reading.type] = [];
      }
      groupedReadings[reading.type]!.add(reading);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...groupedReadings.entries.map((entry) {
          final type = entry.key;
          final readings = entry.value;
          return _buildReadingGroup(type, readings);
        })
      ],
    );
  }

  Widget _buildReadingGroup(String type, List<SensorReading> readings) {
    // Utiliser la lecture la plus récente pour l'affichage principal
    final latestReading = readings.first;
    final formatDate = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForType(type),
                  color: _getColorForType(type),
                ),
                const SizedBox(width: 8),
                Text(
                  _getDisplayNameForType(type),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${latestReading.value.toStringAsFixed(1)} ${latestReading.unit}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getColorForType(type),
                  ),
                ),
                const Spacer(),
                Text(
                  formatDate.format(latestReading.timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour: ${formatDate.format(latestReading.timestamp)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
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
        return Icons.monitor_weight;
      case 'battery':
        return Icons.battery_full;
      default:
        return Icons.sensors;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'temperature':
        return Colors.red;
      case 'humidity':
        return Colors.blue;
      case 'weight':
        return Colors.green;
      case 'battery':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _getDisplayNameForType(String type) {
    switch (type.toLowerCase()) {
      case 'temperature':
        return 'Température';
      case 'humidity':
        return 'Humidité';
      case 'weight':
        return 'Poids';
      case 'battery':
        return 'Batterie';
      default:
        return type;
    }
  }
} 