import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  final String hiveId;

  const AlertsScreen({
    super.key,
    required this.hiveId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2, // TODO: Remplacer par la vraie liste des alertes
        itemBuilder: (context, index) {
          return _buildAlertCard(
            context,
            'Seuil de température dépassé',
            'La température a dépassé 28°C',
            DateTime.now().subtract(Duration(hours: index)),
            AlertType.warning,
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String message,
    DateTime timestamp,
    AlertType type,
  ) {
    final Color color;
    final IconData icon;

    switch (type) {
      case AlertType.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case AlertType.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case AlertType.info:
        color = Colors.blue;
        icon = Icons.info;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                        ),
                  ),
                ),
                Text(
                  _formatTimestamp(timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heures';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }
}

enum AlertType {
  warning,
  error,
  info,
}
