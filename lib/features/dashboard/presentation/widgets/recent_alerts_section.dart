import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecentAlertsSection extends StatelessWidget {
  const RecentAlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

            // Liste d'alertes récentes (simulées pour l'instant)
            _AlertItem(
              icon: '⚠️',
              title: 'Ruche Alpha - Température élevée',
              subtitle: '28.5°C détectée il y a 15 min',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _AlertItem(
              icon: '❌',
              title: 'Ruche Forest-2 - Capteur déconnecté',
              subtitle: 'Aucune donnée depuis 2h',
              color: Colors.red,
            ),
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
  }
}

class _AlertItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
