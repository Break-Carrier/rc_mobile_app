import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/threshold_event.dart';

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
          event.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildDetailChip(
              icon: Icons.water_drop,
              color: Colors.blue,
              text: '${event.humidity.toStringAsFixed(1)}%',
            ),
            const SizedBox(width: 12),
            _buildDetailChip(
              icon: Icons.access_time,
              color: Colors.grey[600]!,
              text: dateFormatted,
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

  EventTheme _getEventTheme() {
    if (event.isExceeded) {
      if (event.isHighTemperature) {
        return EventTheme(
          color: Colors.red,
          icon: Icons.thermostat,
        );
      } else if (event.isLowTemperature) {
        return EventTheme(
          color: Colors.blue,
          icon: Icons.ac_unit,
        );
      } else {
        return EventTheme(
          color: Colors.amber,
          icon: Icons.warning_rounded,
        );
      }
    } else {
      return EventTheme(
        color: Colors.green,
        icon: Icons.check_circle,
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
