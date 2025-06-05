import 'package:flutter/material.dart';

/// Écran des alertes globales pour toutes les ruches
class GlobalAlertsScreen extends StatelessWidget {
  const GlobalAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 Alertes'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // TODO: Remplacer par la vraie liste des alertes globales
        itemBuilder: (context, index) {
          return _buildGlobalAlertCard(
            context,
            index,
          );
        },
      ),
    );
  }

  Widget _buildGlobalAlertCard(BuildContext context, int index) {
    // Données d'exemple - TODO: Remplacer par de vraies données
    final List<Map<String, dynamic>> exampleAlerts = [
      {
        'hive': 'Ruche Alpha',
        'title': 'Température élevée',
        'message': 'Température à 32°C détectée',
        'type': AlertType.warning,
        'time': DateTime.now().subtract(Duration(minutes: 15 * index)),
      },
      {
        'hive': 'Ruche Beta',
        'title': 'Humidité faible',
        'message': 'Humidité descendue à 45%',
        'type': AlertType.info,
        'time': DateTime.now().subtract(Duration(hours: 1 + index)),
      },
      {
        'hive': 'Ruche Forest-2',
        'title': 'Capteur déconnecté',
        'message': 'Aucune donnée depuis 2h',
        'type': AlertType.error,
        'time': DateTime.now().subtract(Duration(hours: 2 + index)),
      },
      {
        'hive': 'Ruche Alpha',
        'title': 'Poids stable',
        'message': 'Poids maintenu à 45kg',
        'type': AlertType.info,
        'time': DateTime.now().subtract(Duration(hours: 6 + index)),
      },
      {
        'hive': 'Ruche Beta',
        'title': 'Activité intense',
        'message': 'Activité des abeilles élevée',
        'type': AlertType.warning,
        'time': DateTime.now().subtract(Duration(days: 1)),
      },
    ];

    final alert = exampleAlerts[index % exampleAlerts.length];
    final Color color;
    final IconData icon;

    switch (alert['type'] as AlertType) {
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône et ruche
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['hive'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        alert['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(alert['time']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              alert['message'],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }
}

enum AlertType {
  warning,
  error,
  info,
}
