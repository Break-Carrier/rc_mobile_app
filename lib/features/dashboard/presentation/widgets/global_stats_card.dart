import 'package:flutter/material.dart';

class GlobalStatsCard extends StatelessWidget {
  final int apiaryCount;
  final int hiveCount;
  final int alertCount;

  const GlobalStatsCard({
    super.key,
    required this.apiaryCount,
    required this.hiveCount,
    required this.alertCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Vue d\'ensemble',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.home_work,
                    label: 'Ruchers',
                    value: apiaryCount.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.hive,
                    label: 'Ruches',
                    value: hiveCount.toString(),
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.warning,
                    label: 'Alertes',
                    value: alertCount.toString(),
                    color: alertCount > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
