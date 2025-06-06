import 'package:flutter/material.dart';
import '../../../apiary/domain/entities/apiary.dart';
import '../../../hive/domain/entities/hive.dart';
import '../../../../core/utils/text_utils.dart';

class GlobalStatsCard extends StatelessWidget {
  final List<Apiary> apiaries;
  final List<Hive> allHives;

  const GlobalStatsCard({
    super.key,
    required this.apiaries,
    required this.allHives,
  });

  @override
  Widget build(BuildContext context) {
    final totalHives = _getTotalHiveCount();
    final alertCount = _getCriticalAlertCount();
    final avgTemp = _getGlobalAverageTemperature();
    final avgHumidity = _getGlobalAverageHumidity();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Résumé Global',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Première ligne de statistiques
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    value: '📊 ${apiaries.length}',
                    label: apiaries.length <= 1 ? 'Rucher' : 'Ruchers',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    value: '🏠 $totalHives',
                    label: TextUtils.getHiveCountText(totalHives),
                    color: Colors.amber.shade700,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    value: '⚠️ $alertCount',
                    label: alertCount <= 1 ? 'Alerte' : 'Alertes',
                    color: alertCount > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Deuxième ligne de statistiques
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    value: '🌡️ ${avgTemp.toStringAsFixed(1)}°C',
                    label: 'Temp. moy.',
                    color: Colors.red.shade600,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    value: '💧 ${avgHumidity.toStringAsFixed(0)}%',
                    label: 'Humid. moy.',
                    color: Colors.blue.shade600,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    value: '✅ ${_getHealthyHivesCount()}',
                    label: 'OK',
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalHiveCount() {
    return allHives.length;
  }

  int _getCriticalAlertCount() {
    // TODO: Implémenter le compte des alertes critiques
    return 2; // Simulé pour l'instant
  }

  double _getGlobalAverageTemperature() {
    // TODO: Calculer la température moyenne réelle
    return 24.5; // Simulé pour l'instant
  }

  double _getGlobalAverageHumidity() {
    // TODO: Calculer l'humidité moyenne réelle
    return 65.0; // Simulé pour l'instant
  }

  int _getHealthyHivesCount() {
    // TODO: Calculer le nombre de ruches en bonne santé
    return _getTotalHiveCount() - 2; // Simulé pour l'instant
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
