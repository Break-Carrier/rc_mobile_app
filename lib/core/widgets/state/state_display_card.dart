import 'package:flutter/material.dart';
import '../../../features/sensor/domain/entities/current_state.dart';
import '../../extensions/datetime_extensions.dart';
import '../../extensions/double_extensions.dart';
import '../../config/app_config.dart';

/// Widget dédié à l'affichage de l'état actuel d'une ruche
class StateDisplayCard extends StatelessWidget {
  final CurrentState? state;
  final VoidCallback? onRefresh;

  const StateDisplayCard({
    super.key,
    required this.state,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(AppConfig.defaultCardMargin),
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultCardMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            if (state != null) ...[
              if (state!.temperature != null)
                _TemperatureTile(
                  temperature: state!.temperature!,
                  timestamp: state!.timestamp,
                ),
              if (state!.temperature != null && state!.humidity != null)
                const SizedBox(height: 8),
              if (state!.humidity != null)
                _HumidityTile(
                  humidity: state!.humidity!,
                  timestamp: state!.timestamp,
                ),
              if (state!.weight != null) ...[
                const SizedBox(height: 8),
                _WeightTile(
                  weight: state!.weight!,
                  timestamp: state!.timestamp,
                ),
              ],
              const SizedBox(height: 8),
              _StatusTile(
                isOnline: state!.isOnline,
                timestamp: state!.timestamp,
              ),
            ] else
              const _NoDataTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.sensors,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'État actuel',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Actualiser',
          ),
      ],
    );
  }
}

/// Tile pour afficher la température
class _TemperatureTile extends StatelessWidget {
  final double temperature;
  final DateTime timestamp;

  const _TemperatureTile({
    required this.temperature,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isOverThreshold = temperature > 35.0; // Seuil par défaut
    return _StateTile(
      icon: Icons.thermostat,
      label: 'Température',
      value: temperature.toTemperatureString(),
      timestamp: timestamp,
      isAlert: isOverThreshold,
      status: temperature.temperatureStatus,
    );
  }
}

/// Tile pour afficher l'humidité
class _HumidityTile extends StatelessWidget {
  final double humidity;
  final DateTime timestamp;

  const _HumidityTile({
    required this.humidity,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return _StateTile(
      icon: Icons.water_drop,
      label: 'Humidité',
      value: humidity.toHumidityString(),
      timestamp: timestamp,
      isAlert: !humidity.isNormalHumidity,
      status: humidity.isNormalHumidity ? 'Normal' : 'Attention',
    );
  }
}

/// Tile pour afficher le poids
class _WeightTile extends StatelessWidget {
  final double weight;
  final DateTime timestamp;

  const _WeightTile({
    required this.weight,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return _StateTile(
      icon: Icons.monitor_weight,
      label: 'Poids',
      value: '${weight.toStringAsFixed(1)} kg',
      timestamp: timestamp,
      isAlert: false,
      status: 'Normal',
    );
  }
}

/// Tile pour afficher le statut de connexion
class _StatusTile extends StatelessWidget {
  final bool isOnline;
  final DateTime timestamp;

  const _StatusTile({
    required this.isOnline,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return _StateTile(
      icon: isOnline ? Icons.wifi : Icons.wifi_off,
      label: 'Statut',
      value: isOnline ? 'En ligne' : 'Hors ligne',
      timestamp: timestamp,
      isAlert: !isOnline,
      status: isOnline ? 'Connecté' : 'Déconnecté',
    );
  }
}

/// Widget générique pour afficher un état de capteur
class _StateTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final DateTime timestamp;
  final bool isAlert;
  final String status;

  const _StateTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.timestamp,
    required this.isAlert,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: AppConfig.animationDuration,
      padding: EdgeInsets.all(AppConfig.defaultPadding * 1.5),
      decoration: BoxDecoration(
        color: isAlert
            ? colorScheme.errorContainer.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isAlert
            ? Border.all(color: colorScheme.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConfig.defaultPadding),
            decoration: BoxDecoration(
              color: isAlert
                  ? colorScheme.error.withValues(alpha: 0.1)
                  : colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isAlert ? colorScheme.error : colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAlert
                            ? colorScheme.error.withValues(alpha: 0.1)
                            : colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isAlert
                                  ? colorScheme.error
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAlert ? colorScheme.error : null,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timestamp.toTimeFormat(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (timestamp.isRecent)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Récent',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget affiché quand aucune donnée n'est disponible
class _NoDataTile extends StatelessWidget {
  const _NoDataTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultCardMargin * 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            AppConfig.noDataMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez la connexion de vos capteurs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
