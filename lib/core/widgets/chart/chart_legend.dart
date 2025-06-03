import 'package:flutter/material.dart';

class ChartLegend extends StatelessWidget {
  final bool showTemperature;
  final bool showHumidity;
  final Function(bool) onTemperatureToggle;
  final Function(bool) onHumidityToggle;

  const ChartLegend({
    super.key,
    required this.showTemperature,
    required this.showHumidity,
    required this.onTemperatureToggle,
    required this.onHumidityToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context: context,
          label: 'Température',
          color: Colors.red,
          isSelected: showTemperature,
          onTap: () => onTemperatureToggle(!showTemperature),
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          context: context,
          label: 'Humidité',
          color: Colors.blue,
          isSelected: showHumidity,
          onTap: () => onHumidityToggle(!showHumidity),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color.withAlpha(26),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(77), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
