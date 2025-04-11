import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sensor_service.dart';
import '../models/current_state.dart';

class ThresholdConfigWidget extends StatefulWidget {
  const ThresholdConfigWidget({super.key});

  @override
  State<ThresholdConfigWidget> createState() => _ThresholdConfigWidgetState();
}

class _ThresholdConfigWidgetState extends State<ThresholdConfigWidget> {
  static const double _minTemperature = 10.0;
  static const double _maxTemperature = 35.0;
  static const double _hysteresisMargin = 0.5; // Marge d'hystérésis (±0.5°C)

  double _targetTemperature = 28.0; // La valeur par défaut dans Firebase est 28
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentThresholds();
    });
  }

  void _loadCurrentThresholds() {
    final sensorService = Provider.of<SensorService>(context, listen: false);
    final currentState = sensorService.lastKnownState;

    if (currentState != null) {
      setState(() {
        // Dans le nouveau format, thresholdHigh est la valeur de seuil principale
        _targetTemperature = currentState.thresholdHigh;
      });
    }
  }

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
            ),
            const SizedBox(height: 16),
            StreamBuilder<CurrentState?>(
              stream: sensorService.getCurrentState(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    sensorService.lastKnownState == null) {
                  return _buildLoadingIndicator();
                }

                if (snapshot.hasError) {
                  return _buildErrorDisplay(snapshot.error.toString());
                }

                final currentState =
                    snapshot.data ?? sensorService.lastKnownState;

                if (currentState == null) {
                  return _buildNoDataDisplay();
                }

                if (_isEditing) {
                  return _buildThresholdEditor(
                      context, currentState, sensorService);
                } else {
                  return _buildThresholdDisplay(context, currentState);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chargement des seuils...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withAlpha(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withAlpha(50)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.amber,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune donnée disponible',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Actualisez pour configurer les seuils de température',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdDisplay(BuildContext context, CurrentState state) {
    // Calcule les seuils à partir de la température cible et de la marge d'hystérésis
    final double thresholdHigh = state.thresholdHigh;
    final double thresholdLow = state.thresholdLow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.purple.withAlpha(50),
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
                    color: Colors.purple.withAlpha(30),
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
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seuil haut',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${thresholdHigh.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seuil bas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${thresholdLow.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.sync,
                            color: Colors.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hystérésis',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.purple.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '±${_hysteresisMargin.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThresholdEditor(
      BuildContext context, CurrentState state, SensorService sensorService) {
    // Dans le nouveau format, on n'a qu'un seul seuil avec des offsets d'hystérésis
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
        Row(
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
                ),
        Slider(
                    value: _targetTemperature,
                    min: _minTemperature,
                    max: _maxTemperature,
          divisions: ((_maxTemperature - _minTemperature) * 2).toInt(),
                    label: '${_targetTemperature.toStringAsFixed(1)}°C',
                    onChanged: (value) {
                      setState(() {
                        _targetTemperature = value;
                      });
                    },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
            OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                  _loadCurrentThresholds(); // Réinitialiser les valeurs
                        });
                      },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Mettre à jour les seuils de température
                  // Dans le nouveau format, on n'a qu'un seuil avec des offsets d'hystérésis
                  // Le seuil bas n'est plus utilisé directement
                  await sensorService.updateThresholds(
                    _targetTemperature -
                        (_hysteresisMargin *
                            2), // Seuil bas (inutilisé dans le nouveau format)
                    _targetTemperature, // Seuil principal
                  );

                        setState(() {
                          _isEditing = false;
                        });

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
                }
              },
                      style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Enregistrer'),
                    ),
                  ],
        ),
      ],
    );
  }
}
