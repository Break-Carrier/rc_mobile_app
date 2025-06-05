import 'package:flutter/material.dart';
import '../../../features/sensor/domain/entities/current_state.dart';

class ThresholdDisplay extends StatelessWidget {
  final CurrentState state;
  final double hysteresisMargin;

  // Seuils par défaut - à terme, ces valeurs pourraient venir d'une configuration
  static const double defaultThresholdHigh = 35.0;
  static const double defaultThresholdLow = 10.0;

  const ThresholdDisplay({
    super.key,
    required this.state,
    required this.hysteresisMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildThresholdValues(),
      ],
    );
  }

  Widget _buildHeader() {
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
          color: Colors.purple.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thermostat,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seuils configurés',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Activez le mode édition pour modifier',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdValues() {
    return Container(
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildThresholdRow(
              icon: Icons.arrow_upward,
              color: Colors.red,
              label: 'Seuil haut',
              value: '${defaultThresholdHigh.toStringAsFixed(1)}°C',
            ),
            const SizedBox(height: 16),
            _buildThresholdRow(
              icon: Icons.arrow_downward,
              color: Colors.blue,
              label: 'Seuil bas',
              value: '${defaultThresholdLow.toStringAsFixed(1)}°C',
            ),
            const SizedBox(height: 16),
            _buildThresholdRow(
              icon: Icons.sync,
              color: Colors.purple,
              label: 'Hystérésis',
              value: '±${hysteresisMargin.toStringAsFixed(1)}°C',
            ),
            if (state.temperature != null) ...[
              const SizedBox(height: 16),
              _buildCurrentTemperatureRow(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTemperatureRow() {
    final temp = state.temperature!;
    final isOverHigh = temp > defaultThresholdHigh;
    final isUnderLow = temp < defaultThresholdLow;
    final isAlert = isOverHigh || isUnderLow;

    return _buildThresholdRow(
      icon: Icons.thermostat,
      color: isAlert ? Colors.orange : Colors.green,
      label: 'Température actuelle',
      value: '${temp.toStringAsFixed(1)}°C',
    );
  }

  Widget _buildThresholdRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
