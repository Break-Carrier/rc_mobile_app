import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive.dart';
import '../services/sensor_service.dart';
import 'package:go_router/go_router.dart';

class HivesScreen extends StatelessWidget {
  final String apiaryId;

  const HivesScreen({
    super.key,
    required this.apiaryId,
  });

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruches'),
      ),
      body: FutureBuilder<List<Hive>>(
        future: sensorService.getHivesByApiary(apiaryId),
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

          final hives = snapshot.data;
          if (hives == null || hives.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hive_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune ruche disponible',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implémenter l'ajout d'une ruche
                    },
                    child: const Text('Ajouter une ruche'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hives.length,
            itemBuilder: (context, index) {
              final hive = hives[index];
              final hasCurrentState = hive.currentState != null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    context.go('/hive/${hive.id}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.hive),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hive.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        if (hive.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            hive.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (hasCurrentState) ...[
                          Row(
                            children: [
                              _buildStateCard(
                                context,
                                Icons.thermostat,
                                'Température',
                                '${hive.currentState!.temperature}°C',
                                Colors.red.withAlpha(30),
                              ),
                              const SizedBox(width: 8),
                              _buildStateCard(
                                context,
                                Icons.water_drop,
                                'Humidité',
                                '${hive.currentState!.humidity}%',
                                Colors.blue.withAlpha(30),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Text(
                            'Aucune donnée disponible',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout d'une ruche
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStateCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
