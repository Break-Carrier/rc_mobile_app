import 'package:flutter/material.dart';
import '../../../features/sensor/domain/entities/current_state.dart';
import '../../factories/service_factory.dart';
import 'threshold_states.dart';
import 'threshold_display.dart';
import 'threshold_editor.dart';

class ThresholdConfig extends StatefulWidget {
  const ThresholdConfig({super.key});

  @override
  State<ThresholdConfig> createState() => _ThresholdConfigState();
}

class _ThresholdConfigState extends State<ThresholdConfig> {
  bool _isEditing = false;
  late final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  Widget build(BuildContext context) {
    // Si aucune ruche n'est sélectionnée, on n'affiche pas le widget
    if (coordinator.currentHiveId == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Configuration des seuils',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: 'Modifier les seuils',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<CurrentState?>(
      stream: coordinator.getCurrentStateStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const ThresholdLoadingState();
        }

        if (snapshot.hasError) {
          return ThresholdErrorState(error: snapshot.error.toString());
        }

        final state = snapshot.data;
        if (state == null) {
          return const ThresholdEmptyState();
        }

        if (_isEditing) {
          return ThresholdEditor(
            currentTemperature: state.temperature ?? 25.0,
            hysteresisMargin: 2.0,
            coordinator: coordinator,
            onCancel: () => setState(() => _isEditing = false),
            onSave: () => setState(() => _isEditing = false),
          );
        } else {
          return ThresholdDisplay(
            state: state,
            hysteresisMargin: 2.0, // Valeur par défaut
          );
        }
      },
    );
  }
}
