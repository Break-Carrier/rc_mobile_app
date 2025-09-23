import 'package:flutter/material.dart';
import '../../domain/entities/hive.dart';
import '../pages/hive_detail_screen.dart';

/// Carte d'affichage d'une ruche
class HiveCard extends StatelessWidget {
  final Hive hive;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HiveCard({
    super.key,
    required this.hive,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hive.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (!hive.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hive.status,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getStatusColor(context),
                    ),
              ),
              if (hive.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  hive.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      iconSize: 18,
                      tooltip: 'Modifier',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 18,
                      tooltip: 'Supprimer',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HiveDetailScreen(hive: hive),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (!hive.isActive) return Theme.of(context).colorScheme.error;
    if (hive.needsInspection) return Theme.of(context).colorScheme.error;

    final daysSinceInspection = hive.lastInspection != null
        ? DateTime.now().difference(hive.lastInspection!).inDays
        : 999;

    if (daysSinceInspection > 14) {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getStatusIcon() {
    if (!hive.isActive) return Icons.pause_circle_outline;
    if (hive.needsInspection) return Icons.warning_outlined;
    return Icons.check_circle_outline;
  }
}
