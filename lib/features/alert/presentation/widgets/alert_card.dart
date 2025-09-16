import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/threshold_event.dart';

/// Widget pour afficher une carte d'alerte
class AlertCard extends StatelessWidget {
  final ThresholdEvent alert;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const AlertCard({
    super.key,
    required this.alert,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getAlertColor(),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône et titre
              Row(
                children: [
                  Icon(
                    _getAlertIcon(),
                    color: _getAlertColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getAlertTitle(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getAlertColor(),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(alert.timestamp),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
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

              const SizedBox(height: 12),

              // Description de l'alerte
              Text(
                alert.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Détails des valeurs
              if (alert.temperature > 0 || alert.humidity > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (alert.temperature > 0) ...[
                      _buildValueChip(
                        context,
                        'Température',
                        '${alert.temperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (alert.humidity > 0)
                      _buildValueChip(
                        context,
                        'Humidité',
                        '${alert.humidity.toStringAsFixed(1)}%',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                  ],
                ),
              ],

              // Actions
              if (onMarkAsRead != null || onDelete != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onMarkAsRead != null) ...[
                      TextButton.icon(
                        onPressed: onMarkAsRead,
                        icon: Icon(
                          alert.isRead
                              ? Icons.mark_email_unread
                              : Icons.mark_email_read,
                          size: 18,
                        ),
                        label: Text(
                          alert.isRead ? 'Marquer non lue' : 'Marquer lue',
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Supprimer'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }

  Widget _buildValueChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
