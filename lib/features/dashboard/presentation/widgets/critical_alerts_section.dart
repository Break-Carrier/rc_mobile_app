import 'package:flutter/material.dart';

class CriticalAlertsSection extends StatelessWidget {
  const CriticalAlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.priority_high,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Alertes Critiques',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<AlertItem>>(
              future: _getCriticalAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final alerts = snapshot.data ?? [];

                if (alerts.isEmpty) {
                  return _buildNoAlertsMessage(context);
                }

                return Column(
                  children: alerts
                      .map((alert) => _buildAlertItem(context, alert))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAlertsMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aucune alerte critique',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Tous vos ruchers fonctionnent normalement',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, AlertItem alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert.severity.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: alert.severity.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            alert.severity.icon,
            color: alert.severity.color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: alert.severity.color,
                  ),
                ),
                if (alert.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    alert.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: alert.severity.color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigation vers détails de l'alerte
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: alert.severity.color,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<AlertItem>> _getCriticalAlerts() async {
    try {
      // TODO: Implémenter la récupération des alertes critiques depuis le service
      // Pour l'instant, on retourne une liste d'exemples
      await Future.delayed(const Duration(milliseconds: 500));

      return [
        // Exemple d'alertes pour démonstration
        // AlertItem(
        //   title: 'Température élevée - Ruche Alpha',
        //   description: '28.5°C dépassement du seuil de 26°C',
        //   severity: AlertSeverity.warning,
        //   timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        // ),
      ];
    } catch (e) {
      return [];
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class AlertItem {
  final String title;
  final String? description;
  final AlertSeverity severity;
  final DateTime timestamp;

  const AlertItem({
    required this.title,
    this.description,
    required this.severity,
    required this.timestamp,
  });
}

enum AlertSeverity {
  warning(Colors.orange, Icons.warning),
  critical(Colors.red, Icons.error),
  info(Colors.blue, Icons.info);

  const AlertSeverity(this.color, this.icon);

  final Color color;
  final IconData icon;
}
