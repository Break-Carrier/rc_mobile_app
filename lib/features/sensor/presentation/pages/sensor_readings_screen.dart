import 'package:flutter/material.dart';
import '../../../../core/models/sensor_reading.dart';
import '../../../../core/models/time_filter.dart';
import '../../../../core/factories/service_factory.dart';

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
  TimeFilter _selectedFilter = TimeFilter.oneHour;
  late final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  void initState() {
    super.initState();
    // Définir la ruche active au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coordinator.setActiveHive(widget.hiveId);
      coordinator.setTimeFilter(_selectedFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectures des capteurs'),
        actions: [
          // Sélecteur de filtre temporel
          PopupMenuButton<TimeFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (TimeFilter filter) {
              setState(() {
                _selectedFilter = filter;
              });
              coordinator.setTimeFilter(filter);
            },
            itemBuilder: (BuildContext context) {
              return TimeFilter.values.map((TimeFilter filter) {
                return PopupMenuItem<TimeFilter>(
                  value: filter,
                  child: Text(filter.displayName),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre sélectionné
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Période: ${_selectedFilter.displayName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Graphique des lectures
          Expanded(
            child: StreamBuilder<List<SensorReading>>(
              stream: coordinator.getSensorReadingsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                final readings = snapshot.data;
                if (readings == null || readings.isEmpty) {
                  return const Center(
                    child: Text('Aucune donnée disponible'),
                  );
                }

                // Trouver les valeurs actuelles
                final latestReading = readings.first;
                final temperature = latestReading.value;
                final humidity = readings
                    .firstWhere(
                      (reading) => reading.type == 'humidity',
                      orElse: () => latestReading,
                    )
                    .value;

                return Column(
                  children: [
                    // Placeholder pour le graphique
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Graphique des lectures',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'TODO: Implémenter le graphique',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Informations détaillées
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoCard(
                            context,
                            'Température',
                            '${temperature.toStringAsFixed(1)}°C',
                            Icons.thermostat,
                            Colors.red,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoCard(
                            context,
                            'Humidité',
                            '${humidity.toStringAsFixed(1)}%',
                            Icons.water_drop,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
