import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/bloc/hive_details_bloc.dart';
import '../../data/repositories/hive_repository.dart';
import '../../../../services/sensor_service.dart';

class HiveDetailsScreen extends StatelessWidget {
  final String hiveId;

  const HiveDetailsScreen({
    super.key,
    required this.hiveId,
  });

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context, listen: false);

    return BlocProvider(
      create: (context) => HiveDetailsBloc(
        hiveRepository: HiveRepository(sensorService: sensorService),
      )..add(LoadHiveDetails(hiveId: hiveId)),
      child: _HiveDetailsView(hiveId: hiveId),
    );
  }
}

class _HiveDetailsView extends StatelessWidget {
  final String hiveId;

  const _HiveDetailsView({required this.hiveId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HiveDetailsBloc, HiveDetailsState>(
      builder: (context, state) {
        final title = state is HiveDetailsLoaded && state.hive != null
            ? state.hive!.name
            : 'Ruche $hiveId';

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<HiveDetailsBloc>().add(RefreshHiveDetails());
                },
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HiveDetailsState state) {
    if (state is HiveDetailsInitial || state is HiveDetailsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is HiveDetailsLoaded) {
      return SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec les informations principales
            _buildHeader(context, state),

            // Navigation vers les sous-pages
            _buildNavigation(context),
          ],
        ),
      );
    } else if (state is HiveDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.message),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<HiveDetailsBloc>().add(
                      LoadHiveDetails(hiveId: hiveId),
                    );
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildHeader(BuildContext context, HiveDetailsLoaded state) {
    final currentState = state.currentState;
    final hasData = currentState != null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.amber,
            child: Icon(Icons.hive, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (state.hive != null) ...[
            Text(
              state.hive!.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (state.hive!.description != null) ...[
              const SizedBox(height: 8),
              Text(
                state.hive!.description!,
                textAlign: TextAlign.center,
              ),
            ],
          ] else ...[
            Text(
              'Ruche $hiveId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
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
                _buildCurrentStateItem(
                  'Température',
                  '${currentState.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.redAccent,
                ),
                const SizedBox(width: 24),
                _buildCurrentStateItem(
                  'Humidité',
                  '${currentState.humidity.toStringAsFixed(1)}%',
                  Icons.water_drop,
                  Colors.blueAccent,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildNavigationCard(
            context,
            'Lectures des capteurs',
            Icons.sensors,
            () => context.go('/hive/$hiveId/readings'),
          ),
          _buildNavigationCard(
            context,
            'Alertes',
            Icons.notifications,
            () => context.go('/hive/$hiveId/alerts'),
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
    );
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
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} heures';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }
}
