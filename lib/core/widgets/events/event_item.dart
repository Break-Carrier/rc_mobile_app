import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../features/sensor/domain/entities/threshold_event.dart';

class EventItem extends StatelessWidget {
  final ThresholdEvent event;

  const EventItem({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final eventTheme = _getEventTheme();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: eventTheme.color.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {}, // Pour l'effet de ripple
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventIcon(eventTheme),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEventContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventIcon(EventTheme theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        theme.icon,
        color: theme.color,
        size: 24,
      ),
    );
  }

  Widget _buildEventContent() {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    final dateFormatted = dateFormatter.format(event.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getEventDescription(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildDetailChip(
              icon: _getTypeIcon(),
              color: _getTypeColor(),
              text: '${event.value.toStringAsFixed(1)} ${_getUnit()}',
            ),
            const SizedBox(width: 12),
            _buildDetailChip(
              icon: Icons.access_time,
              color: Colors.grey[600]!,
              text: dateFormatted,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildDetailChip(
              icon: Icons.warning,
              color: _getSeverityColor(),
              text:
                  'Seuil: ${event.threshold.toStringAsFixed(1)} ${_getUnit()}',
            ),
            const SizedBox(width: 12),
            if (event.isResolved)
              _buildDetailChip(
                icon: Icons.check_circle,
                color: Colors.green,
                text: 'Résolu',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _getEventDescription() {
    final typeText = _getTypeText();
    final severityText = _getSeverityText();

    if (event.isResolved) {
      return '$typeText - $severityText (Résolu)';
    } else {
      return '$typeText - $severityText';
    }
  }

  String _getTypeText() {
    switch (event.type.toLowerCase()) {
      case 'temperature':
        return 'Température';
      case 'humidity':
        return 'Humidité';
      case 'weight':
        return 'Poids';
      default:
        return event.type;
    }
  }

  String _getSeverityText() {
    switch (event.severity.toLowerCase()) {
      case 'critical':
        return 'Critique';
      case 'high':
        return 'Élevé';
      case 'medium':
        return 'Moyen';
      case 'low':
        return 'Faible';
      default:
        return event.severity;
    }
  }

  String _getUnit() {
    switch (event.type.toLowerCase()) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'weight':
        return 'kg';
      default:
        return '';
    }
  }

  IconData _getTypeIcon() {
    switch (event.type.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'weight':
        return Icons.monitor_weight;
      default:
        return Icons.sensors;
    }
  }

  Color _getTypeColor() {
    switch (event.type.toLowerCase()) {
      case 'temperature':
        return Colors.red;
      case 'humidity':
        return Colors.blue;
      case 'weight':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getSeverityColor() {
    switch (event.severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  EventTheme _getEventTheme() {
    if (event.isResolved) {
      return EventTheme(
        color: Colors.green,
        icon: Icons.check_circle,
      );
    }

    switch (event.severity.toLowerCase()) {
      case 'critical':
        return EventTheme(
          color: Colors.red,
          icon: Icons.error,
        );
      case 'high':
        return EventTheme(
          color: Colors.orange,
          icon: Icons.warning,
        );
      case 'medium':
        return EventTheme(
          color: Colors.yellow,
          icon: Icons.info,
        );
      case 'low':
        return EventTheme(
          color: Colors.blue,
          icon: Icons.info_outline,
        );
      default:
        return EventTheme(
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }
}

class EventTheme {
  final Color color;
  final IconData icon;

  EventTheme({
    required this.color,
    required this.icon,
  });
}
