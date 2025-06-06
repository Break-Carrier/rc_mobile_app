import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../apiary/domain/entities/apiary.dart';
import '../../../hive/domain/entities/hive.dart';
import '../../../../core/models/apiary_status.dart';
import '../../../../core/utils/text_utils.dart';

class ApiariesSection extends StatelessWidget {
  final List<Apiary> apiaries;
  final Map<String, List<Hive>> hivesByApiary;

  const ApiariesSection({
    super.key,
    required this.apiaries,
    required this.hivesByApiary,
  });

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
                const Icon(Icons.home_work, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Mes Ruchers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste compacte des ruchers
            ...apiaries.map((apiary) => _ApiaryCard(
                  apiary: apiary,
                  hiveCount: hivesByApiary[apiary.id]?.length ?? 0,
                )),
          ],
        ),
      ),
    );
  }
}

class _ApiaryCard extends StatelessWidget {
  final Apiary apiary;
  final int hiveCount;

  const _ApiaryCard({
    required this.apiary,
    required this.hiveCount,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getApiaryStatus(apiary);
    final statusIcon = status.emoji;
    final statusColor = status.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToApiary(context, apiary),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Text(
                '🏡',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apiary.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${TextUtils.getHiveCountText(hiveCount)} • ${apiary.location}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                statusIcon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ApiaryStatus _getApiaryStatus(Apiary apiary) {
    // TODO: Implémenter la logique de calcul du statut réel
    if (hiveCount == 0) return ApiaryStatus.critical;
    if (apiary.name.contains('Forêt')) return ApiaryStatus.warning;
    if (apiary.name.contains('Prairie')) return ApiaryStatus.critical;
    return ApiaryStatus.normal;
  }

  void _navigateToApiary(BuildContext context, Apiary apiary) {
    context.go('/apiary/${apiary.id}/hives');
  }
}
