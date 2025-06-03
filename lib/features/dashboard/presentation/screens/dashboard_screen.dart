import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../services/sensor_service.dart';
import '../../../../widgets/current_state_widget.dart';
import '../../../../core/widgets/threshold/threshold_config.dart';
import '../../../../core/widgets/events/threshold_events.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../widgets/average_temperature_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);

    return BlocProvider(
      create: (context) => DashboardBloc(
        sensorService: sensorService,
      )..add(LoadDashboardData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de Bord'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Implémenter l'ajout d'une ruche
              },
            ),
          ],
        ),
        body: _DashboardView(),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardInitial || state is DashboardLoading) {
          return _buildLoadingScreen();
        } else if (state is DashboardError) {
          return _buildErrorScreen(context, state.message);
        } else if (state is DashboardLoaded) {
          return state.selectedHiveId == null
              ? _buildNoHivesScreen(context)
              : _buildDashboardContent(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboardData());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélecteur de ruche
            if (state.hives.length > 1) _buildHiveSelector(context, state),

            // Widget d'état actuel pour la ruche sélectionnée
            CurrentStateWidget(
              hiveId: state.selectedHiveId!,
              sensorService: Provider.of<SensorService>(context),
            ),

            const ThresholdConfig(),

            // Graphique de température moyenne pour tout le rucher
            state.apiaries.isNotEmpty
                ? AverageTemperatureChart(
                    readings: state.averageTemperatureReadings,
                    currentFilter: state.currentTimeFilter,
                    onTimeFilterChanged: (filter) {
                      context.read<DashboardBloc>().add(
                            ChangeTimeFilter(timeFilter: filter),
                          );
                    },
                  )
                : const SizedBox(),

            const ThresholdEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildHiveSelector(BuildContext context, DashboardLoaded state) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          value: state.selectedHiveId,
          isExpanded: true,
          hint: const Text('Sélectionner une ruche'),
          onChanged: (String? newValue) {
            if (newValue != null) {
              // Mise à jour directe dans le service puisque d'autres widgets en dépendent
              Provider.of<SensorService>(context, listen: false)
                  .setCurrentHive(newValue);

              // Force refresh
              context.read<DashboardBloc>().add(RefreshDashboardData());
            }
          },
          items: state.hives.map<DropdownMenuItem<String>>((hive) {
            return DropdownMenuItem<String>(
              value: hive.id,
              child: Text(hive.name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement du tableau de bord...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Récupération des données...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<DashboardBloc>().add(LoadDashboardData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoHivesScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hive_outlined,
            size: 64,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune ruche disponible',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez une ruche pour commencer',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/apiaries');
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une ruche'),
          ),
        ],
      ),
    );
  }
}
