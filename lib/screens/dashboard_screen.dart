import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../services/sensor_service.dart';
import '../widgets/current_state_widget.dart';
import '../core/widgets/chart/sensor_chart.dart';
import '../core/widgets/events/threshold_events.dart';
import '../core/widgets/threshold/threshold_config.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(
        sensorService: Provider.of<SensorService>(context, listen: false),
      )..add(LoadDashboard()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DashboardBloc>().add(RefreshDashboard()),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() => const _LoadingWidget(),
            DashboardLoading() => const _LoadingWidget(),
            DashboardError() => _ErrorWidget(message: state.message),
            DashboardLoaded() => _LoadedContent(state: state),
            _ => const _LoadingWidget(),
          };
        },
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initialisation en cours...'),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<DashboardBloc>().add(LoadDashboard()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final DashboardLoaded state;

  const _LoadedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.hives.isEmpty) {
      return const _NoHivesWidget();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboard());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélecteur de ruche
            if (state.hives.length > 1)
              _HiveSelector(
                hives: state.hives,
                selectedHiveId: state.selectedHiveId,
                onChanged: (hiveId) {
                  if (hiveId != null) {
                    context.read<DashboardBloc>().add(SelectHive(hiveId));
                  }
                },
              ),

            // État actuel
            if (state.selectedHiveId != null)
              CurrentStateWidget(
                hiveId: state.selectedHiveId!,
                sensorService: Provider.of<SensorService>(context),
              ),

            // Configuration des seuils
            const ThresholdConfig(),

            // Graphique des capteurs
            if (state.apiaries.isNotEmpty)
              SensorChart(
                apiaryId: state.apiaries.first.id,
                showAverageTemperature: true,
              )
            else
              const SensorChart(),

            // Événements de dépassement de seuil
            const ThresholdEvents(),
          ],
        ),
      ),
    );
  }
}

class _NoHivesWidget extends StatelessWidget {
  const _NoHivesWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hive_outlined,
            size: 64,
            color: Colors.amber,
          ),
          SizedBox(height: 16),
          Text(
            'Aucune ruche disponible',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez une ruche pour commencer',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _HiveSelector extends StatelessWidget {
  final List<dynamic> hives;
  final String? selectedHiveId;
  final ValueChanged<String?> onChanged;

  const _HiveSelector({
    required this.hives,
    required this.selectedHiveId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          value: selectedHiveId,
          isExpanded: true,
          hint: const Text('Sélectionner une ruche'),
          onChanged: onChanged,
          items: hives.map<DropdownMenuItem<String>>((hive) {
            return DropdownMenuItem<String>(
              value: hive.id,
              child: Text(hive.name),
            );
          }).toList(),
        ),
      ),
    );
  }
}
