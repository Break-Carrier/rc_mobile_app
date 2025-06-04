import 'package:flutter/material.dart';
import '../../../../core/models/apiary.dart';
import '../../../../core/models/apiary_status.dart';

class ApiaryOverviewCard extends StatelessWidget {
  final Apiary apiary;
  final VoidCallback onTap;

  const ApiaryOverviewCard({
    super.key,
    required this.apiary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apiary.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                apiary.location,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),

              const SizedBox(height: 16),

              // Informations des ruches
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      Icons.hive,
                      '${apiary.hiveIds.length}',
                      'Ruches',
                      Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<double?>(
                      future: _getAverageTemperature(),
                      builder: (context, snapshot) {
                        final temp = snapshot.data;
                        return _buildInfoItem(
                          context,
                          Icons.thermostat,
                          temp != null ? '${temp.toStringAsFixed(1)}°C' : '--',
                          'Temp. moy.',
                          Colors.red,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      Icons.notifications,
                      '0', // TODO: Calculer les alertes
                      'Alertes',
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              if (apiary.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  apiary.description!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Indicateur de navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Voir les ruches',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    // TODO: Calculer le statut réel basé sur les données des capteurs
    final status = _getApiaryStatus();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  ApiaryStatus _getApiaryStatus() {
    // TODO: Implémenter la logique de calcul du statut
    // Basé sur les alertes, la connectivité des capteurs, etc.
    if (apiary.hiveIds.isEmpty) return ApiaryStatus.warning;
    return ApiaryStatus.normal;
  }

  Future<double?> _getAverageTemperature() async {
    try {
      // TODO: Implémenter le calcul de température moyenne pour le rucher
      return null;
    } catch (e) {
      return null;
    }
  }
}
