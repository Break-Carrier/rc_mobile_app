import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/sensor_service.dart';
import '../../../models/current_state.dart';
import 'threshold_states.dart';
import 'threshold_display.dart';
import 'threshold_editor.dart';

class ThresholdConfig extends StatefulWidget {
  const ThresholdConfig({super.key});

  @override
  State<ThresholdConfig> createState() => _ThresholdConfigState();
}

class _ThresholdConfigState extends State<ThresholdConfig> {
  static const double _hysteresisMargin = 0.5; // Marge d'hystérésis (±0.5°C)
  
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);
    final currentHiveId = sensorService.currentHiveId;

    // Si aucune ruche n'est sélectionnée, on n'affiche pas le widget
    if (currentHiveId == null) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildContent(sensorService),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Configuration des seuils',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          value: _isEditing,
          onChanged: (value) {
            setState(() {
              _isEditing = value;
            });
          },
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildContent(SensorService sensorService) {
    return StreamBuilder<CurrentState?>(
      stream: sensorService.getCurrentState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            sensorService.lastKnownState == null) {
          return const ThresholdLoadingState();
        }

        if (snapshot.hasError) {
          return ThresholdErrorState(error: snapshot.error.toString());
        }

        final currentState = snapshot.data ?? sensorService.lastKnownState;

        if (currentState == null) {
          return const ThresholdEmptyState();
        }

        if (_isEditing) {
          return ThresholdEditor(
            currentTemperature: currentState.thresholdHigh,
            hysteresisMargin: _hysteresisMargin,
            sensorService: sensorService,
            onCancel: () {
              setState(() {
                _isEditing = false;
              });
            },
            onSave: () {
              setState(() {
                _isEditing = false;
              });
            },
          );
        } else {
          return ThresholdDisplay(
            state: currentState,
            hysteresisMargin: _hysteresisMargin,
          );
        }
      },
    );
  }
} 