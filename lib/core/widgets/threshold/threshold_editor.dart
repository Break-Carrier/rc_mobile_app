import 'package:flutter/material.dart';
import '../../services/hive_service_coordinator.dart';

class ThresholdEditor extends StatefulWidget {
  final double currentTemperature;
  final double hysteresisMargin;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final HiveServiceCoordinator coordinator;

  const ThresholdEditor({
    super.key,
    required this.currentTemperature,
    required this.hysteresisMargin,
    required this.onCancel,
    required this.onSave,
    required this.coordinator,
  });

  @override
  State<ThresholdEditor> createState() => _ThresholdEditorState();
}

class _ThresholdEditorState extends State<ThresholdEditor> {
  static const double _minTemperature = 10.0;
  static const double _maxTemperature = 35.0;

  late double _targetTemperature;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _targetTemperature = widget.currentTemperature;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ajustez le seuil de température',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTemperatureRange(),
        _buildSlider(),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildTemperatureRange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_minTemperature.toStringAsFixed(1)}°C',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${_maxTemperature.toStringAsFixed(1)}°C',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    return Slider(
      value: _targetTemperature,
      min: _minTemperature,
      max: _maxTemperature,
      divisions: ((_maxTemperature - _minTemperature) * 2).toInt(),
      label: '${_targetTemperature.toStringAsFixed(1)}°C',
      onChanged: _isSaving
          ? null
          : (value) {
              setState(() {
                _targetTemperature = value;
              });
            },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: _isSaving ? null : widget.onCancel,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Mettre à jour les seuils de température
      await widget.coordinator.updateThresholds(
        _targetTemperature - (widget.hysteresisMargin * 2), // Seuil bas
        _targetTemperature, // Seuil principal
      );

      widget.onSave();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seuils mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
