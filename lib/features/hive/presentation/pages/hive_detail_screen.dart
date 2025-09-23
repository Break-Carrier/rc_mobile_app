import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hive.dart';
import '../../../sensor/domain/entities/hive_sensor_data.dart';
import '../../../sensor/domain/entities/sensor_reading.dart';
import '../../../sensor/data/repositories/sensor_repository_impl.dart';
import '../../../sensor/presentation/widgets/sensor_chart_widget.dart';
import '../../data/injection/hive_injection.dart';
import '../bloc/hive_bloc.dart';
import '../bloc/hive_event.dart';
import '../widgets/create_hive_dialog.dart';

/// Écran de détail d'une ruche
class HiveDetailScreen extends StatelessWidget {
  final Hive hive;

  const HiveDetailScreen({
    super.key,
    required this.hive,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HiveInjection.getHiveBloc(),
      child: _HiveDetailView(hive: hive),
    );
  }
}

class _HiveDetailView extends StatefulWidget {
  final Hive hive;

  const _HiveDetailView({required this.hive});

  @override
  State<_HiveDetailView> createState() => _HiveDetailViewState();
}

class _HiveDetailViewState extends State<_HiveDetailView> {
  List<SensorReading> _sensorHistory = [];
  bool _isLoadingHistory = false;
  late final SensorRepositoryImpl _sensorRepository;

  @override
  void initState() {
    super.initState();
    // Créer une instance simple du repository pour les capteurs
    _sensorRepository = SensorRepositoryImpl(
      null, // HiveServiceCoordinator - pas nécessaire pour les données mockées
      null, // FirebaseService - pas nécessaire pour les données mockées
    );
    _loadSensorHistory();
  }

  Future<void> _loadSensorHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await _sensorRepository.getSensorHistory(widget.hive.id);
      setState(() {
        _sensorHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      debugPrint('Erreur lors du chargement de l\'historique: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hive.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditHiveDialog(context),
            tooltip: 'Modifier',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(widget.hive.isActive ? Icons.pause : Icons.play_arrow),
                    const SizedBox(width: 8),
                    Text(widget.hive.isActive ? 'Désactiver' : 'Activer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'inspection',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Marquer inspection'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HiveStatusCard(hive: widget.hive),
            const SizedBox(height: 16),
            _HiveSensorDataCard(sensorData: widget.hive.sensorData),
            const SizedBox(height: 16),
            _buildSensorChart(),
            const SizedBox(height: 16),
            _HiveInfoCard(hive: widget.hive),
            if (widget.hive.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _HiveDescriptionCard(hive: widget.hive),
            ],
            const SizedBox(height: 16),
            _HiveActionsCard(
              hive: widget.hive,
              onInspection: () => _markInspection(context),
              onEdit: () => _showEditHiveDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorChart() {
    if (_isLoadingHistory) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return SensorChartWidget(
      readings: _sensorHistory,
      title: 'Historique des capteurs',
      showTemperature: true,
      showHumidity: true,
    );
  }

  void _showEditHiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HiveBloc>(),
        child: CreateHiveDialog(
          apiaryId: widget.hive.apiaryId,
          hive: widget.hive,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'toggle_status':
        _toggleHiveStatus(context);
        break;
      case 'inspection':
        _markInspection(context);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _toggleHiveStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(widget.hive.isActive ? 'Ruche désactivée' : 'Ruche activée'),
      ),
    );
  }

  void _markInspection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inspection marquée')),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la ruche'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer "${widget.hive.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<HiveBloc>().add(DeleteHiveRequested(widget.hive.id));
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Widget de carte de statut de la ruche
class _HiveStatusCard extends StatelessWidget {
  final Hive hive;

  const _HiveStatusCard({required this.hive});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);
    final needsAttention = hive.needsInspection || !hive.isActive;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: needsAttention
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getStatusIcon(), color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut actuel',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    hive.status,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (!hive.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (!hive.isActive) return Theme.of(context).colorScheme.error;
    if (hive.needsInspection) return Theme.of(context).colorScheme.error;

    final daysSinceInspection = hive.lastInspection != null
        ? DateTime.now().difference(hive.lastInspection!).inDays
        : 999;

    if (daysSinceInspection > 14) {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getStatusIcon() {
    if (!hive.isActive) return Icons.pause_circle_outline;
    if (hive.needsInspection) return Icons.warning_outlined;
    return Icons.check_circle_outline;
  }
}

/// Widget de carte d'informations de la ruche
class _HiveInfoCard extends StatelessWidget {
  final Hive hive;

  const _HiveInfoCard({required this.hive});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.tag,
              label: 'Identifiant',
              value: hive.id,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Créée le',
              value: _formatDate(hive.createdAt),
            ),
            if (hive.updatedAt != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.update,
                label: 'Modifiée le',
                value: _formatDate(hive.updatedAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Widget de carte de description de la ruche
class _HiveDescriptionCard extends StatelessWidget {
  final Hive hive;

  const _HiveDescriptionCard({required this.hive});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              hive.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de carte d'actions de la ruche
class _HiveActionsCard extends StatelessWidget {
  final Hive hive;
  final VoidCallback onInspection;
  final VoidCallback onEdit;

  const _HiveActionsCard({
    required this.hive,
    required this.onInspection,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onInspection,
                    icon: const Icon(Icons.search),
                    label: const Text('Marquer inspection'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: onEdit,
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de carte pour afficher les données des capteurs
class _HiveSensorDataCard extends StatelessWidget {
  final HiveSensorData? sensorData;

  const _HiveSensorDataCard({this.sensorData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sensors,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Données des capteurs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sensorData != null) ...[
              // Température et Humidité en vedette
              Row(
                children: [
                  Expanded(
                    child: _TemperatureCard(sensorData!.temperature),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HumidityCard(sensorData!.humidity),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // État du couvert
              _SensorDataRow(
                icon: sensorData!.coverState == CoverState.open
                    ? Icons.open_in_full
                    : Icons.close_fullscreen,
                label: 'Couvert',
                value: sensorData!.coverState == CoverState.open
                    ? 'Ouvert'
                    : 'Fermé',
                color: sensorData!.coverState == CoverState.open
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(height: 12),

              // État de la LED
              _SensorDataRow(
                icon: sensorData!.ledState == LedState.on
                    ? Icons.lightbulb
                    : Icons.lightbulb_outline,
                label: 'LED',
                value:
                    sensorData!.ledState == LedState.on ? 'Allumée' : 'Éteinte',
                color: sensorData!.ledState == LedState.on
                    ? Colors.amber
                    : Colors.grey,
              ),
            ] else ...[
              // Message quand les données ne sont pas disponibles
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.sensors_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune donnée de capteur disponible',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Les capteurs de cette ruche ne sont pas encore connectés ou configurés.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher la température en vedette
class _TemperatureCard extends StatelessWidget {
  final double temperature;

  const _TemperatureCard(this.temperature);

  @override
  Widget build(BuildContext context) {
    final color = _getTemperatureColor(temperature);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.thermostat,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            '${temperature.toStringAsFixed(1)}°C',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Température',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 20) return Colors.blue;
    if (temperature > 30) return Colors.red;
    return Colors.green;
  }
}

/// Widget pour afficher l'humidité en vedette
class _HumidityCard extends StatelessWidget {
  final double humidity;

  const _HumidityCard(this.humidity);

  @override
  Widget build(BuildContext context) {
    final color = _getHumidityColor(humidity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            '${humidity.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Humidité',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 40) return Colors.orange;
    if (humidity > 80) return Colors.blue;
    return Colors.green;
  }
}

/// Widget pour afficher une ligne de données de capteur
class _SensorDataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SensorDataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

/// Widget réutilisable pour afficher une ligne d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
