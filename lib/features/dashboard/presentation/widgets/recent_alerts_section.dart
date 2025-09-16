import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../alert/di/alert_injection.dart';
import '../../../alert/presentation/bloc/alert_bloc.dart';
import '../../../alert/domain/entities/threshold_event.dart';

class RecentAlertsSection extends StatefulWidget {
  const RecentAlertsSection({super.key});

  @override
  State<RecentAlertsSection> createState() => _RecentAlertsSectionState();
}

class _RecentAlertsSectionState extends State<RecentAlertsSection> {
  @override
  void initState() {
    super.initState();
    // Charger les alertes récentes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertBloc>().add(const LoadAlerts(limit: 3));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlertInjection.getAlertBloc(),
      child: BlocBuilder<AlertBloc, AlertState>(
        builder: (context, state) {
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notification_important,
                          color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Alertes Récentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Contenu des alertes
                  _buildAlertsContent(state),

                  const SizedBox(height: 12),

                  // Bouton voir toutes les alertes
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go('/alerts'),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Voir toutes les alertes'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertsContent(AlertState state) {
    if (state is AlertLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is AlertError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Erreur lors du chargement des alertes',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is AlertLoaded) {
      if (state.alerts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aucune alerte active',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: state.alerts.take(3).map((alert) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AlertItem(alert: alert),
          );
        }).toList(),
      );
    }

    // État initial ou autre
    return const SizedBox.shrink();
  }
}

class _AlertItem extends StatelessWidget {
  final ThresholdEvent alert;

  const _AlertItem({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAlertColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getAlertColor().withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(_getAlertIcon(), color: _getAlertColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAlertTitle(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getAlertColor(),
                    fontSize: 14,
                  ),
                ),
                Text(
                  _getAlertSubtitle(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (!alert.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Color _getAlertColor() {
    if (alert.isExceeded) {
      if (alert.isHighTemperature || alert.isLowTemperature) {
        return Colors.red;
      }
      return Colors.orange;
    }
    return Colors.green;
  }

  IconData _getAlertIcon() {
    if (alert.isExceeded) {
      if (alert.isHighTemperature || alert.isLowTemperature) {
        return Icons.thermostat;
      }
      return Icons.warning;
    }
    return Icons.check_circle;
  }

  String _getAlertTitle() {
    if (alert.isExceeded) {
      if (alert.isHighTemperature) {
        return 'Température élevée';
      } else if (alert.isLowTemperature) {
        return 'Température basse';
      }
      return 'Seuil dépassé';
    }
    return 'Retour à la normale';
  }

  String _getAlertSubtitle() {
    final now = DateTime.now();
    final difference = now.difference(alert.timestamp);

    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      timeAgo = 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      timeAgo = 'Il y a ${difference.inHours}h';
    } else {
      timeAgo = 'Il y a ${difference.inDays}j';
    }

    if (alert.temperature > 0) {
      return '${alert.temperature.toStringAsFixed(1)}°C - $timeAgo';
    } else if (alert.humidity > 0) {
      return '${alert.humidity.toStringAsFixed(1)}% - $timeAgo';
    }

    return timeAgo;
  }
}
