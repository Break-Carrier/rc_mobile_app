import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../sensor/domain/entities/hive.dart';
import '../../../sensor/domain/entities/current_state.dart';
import '../../../../core/factories/service_factory.dart';

class HiveDetailsScreen extends StatefulWidget {
  final String hiveId;

  const HiveDetailsScreen({
    super.key,
    required this.hiveId,
  });

  @override
  State<HiveDetailsScreen> createState() => _HiveDetailsScreenState();
}

class _HiveDetailsScreenState extends State<HiveDetailsScreen> {
  late final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  void initState() {
    super.initState();
    // Définir la ruche active au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coordinator.setActiveHive(widget.hiveId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Hive?>(
          future: _getHiveById(widget.hiveId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Chargement...');
            }

            if (snapshot.hasData) {
              return Text(snapshot.data!.name);
            }

            return Text('Ruche ${widget.hiveId}');
          },
        ),
      ),
      body: StreamBuilder<CurrentState?>(
        stream: coordinator.getCurrentStateStream(),
        builder: (context, snapshot) {
          final currentState = snapshot.data;
          final hasData = currentState != null;

          return Column(
            children: [
              // En-tête avec les informations principales
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.hive, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Hive?>(
                      future: _getHiveById(widget.hiveId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              Text(
                                snapshot.data!.name,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (snapshot.data!.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.data!.description!,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          );
                        }

                        return Text(
                          'Ruche ${widget.hiveId}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasData
                          ? 'Dernière mise à jour: ${_formatTimestamp(currentState.timestamp)}'
                          : 'Aucune donnée disponible',
                    ),
                    if (hasData) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentState.temperature != null)
                            _buildCurrentStateItem(
                              'Température',
                              '${currentState.temperature!.toStringAsFixed(1)}°C',
                              Icons.thermostat,
                              Colors.redAccent,
                            ),
                          if (currentState.temperature != null &&
                              currentState.humidity != null)
                            const SizedBox(width: 24),
                          if (currentState.humidity != null)
                            _buildCurrentStateItem(
                              'Humidité',
                              '${currentState.humidity!.toStringAsFixed(1)}%',
                              Icons.water_drop,
                              Colors.blueAccent,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Navigation vers les sous-pages
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildNavigationCard(
                      context,
                      'Lectures des capteurs',
                      Icons.sensors,
                      () => context.go('/hive/${widget.hiveId}/readings'),
                    ),
                    _buildNavigationCard(
                      context,
                      'Alertes',
                      Icons.notifications,
                      () => context.go('/hive/${widget.hiveId}/alerts'),
                    ),
                    _buildNavigationCard(
                      context,
                      'Configuration',
                      Icons.settings,
                      () {
                        // TODO: Implémenter la navigation vers la configuration
                      },
                    ),
                    _buildNavigationCard(
                      context,
                      'Historique',
                      Icons.history,
                      () {
                        // TODO: Implémenter la navigation vers l'historique
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Hive?> _getHiveById(String hiveId) async {
    try {
      final apiaries = await coordinator.getApiaries();
      for (final apiary in apiaries) {
        final hives = await coordinator.getHivesForApiary(apiary.id);
        for (final hive in hives) {
          if (hive.id == hiveId) {
            return hive;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildCurrentStateItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
