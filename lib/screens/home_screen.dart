import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../widgets/current_state_widget.dart';
import '../widgets/sensor_readings_chart.dart';
import '../widgets/threshold_events_widget.dart';
import '../widgets/threshold_config_widget.dart';
import '../services/sensor_service.dart';
import '../models/hive.dart';
import '../models/apiary.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _timeoutExpired = false;
  Timer? _timeoutTimer;
  String? _selectedHiveId;
  List<Apiary> _apiaries = [];
  List<Hive> _hives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Définir un timeout de 10 secondes pour l'initialisation
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        _timeoutExpired = true;
      });
    });

    // Charger les données initiales
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final sensorService = Provider.of<SensorService>(context, listen: false);

    if (sensorService.isInitialized) {
      try {
        // Récupérer les ruchers
        _apiaries = await sensorService.getApiaries();

        if (_apiaries.isNotEmpty) {
          // Récupérer les ruches du premier rucher
          _hives = await sensorService.getHivesForApiary(_apiaries.first.id);

          if (_hives.isNotEmpty) {
            // Sélectionner la première ruche
            setState(() {
              _selectedHiveId = _hives.first.id;
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('❌ Error loading initial data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);

    // Si le timeout a expiré et services toujours pas initialisés
    if (_timeoutExpired && !sensorService.isInitialized) {
      return _buildErrorScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implémenter l'ajout d'une ruche
            },
          ),
        ],
      ),
      body: !sensorService.isInitialized || _isLoading
          ? _buildLoadingScreen()
          : _selectedHiveId == null
              ? _buildNoHivesScreen()
              : RefreshIndicator(
                  onRefresh: () async {
                    // Rafraîchir toutes les données lors d'un swipe vers le bas
                    await Provider.of<SensorService>(context, listen: false)
                        .refreshAllData();
                    await _loadInitialData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sélecteur de ruche
                        if (_hives.length > 1) _buildHiveSelector(),

                        CurrentStateWidget(
                          hiveId: _selectedHiveId!,
                          sensorService: Provider.of<SensorService>(context),
                        ),
                        ThresholdConfigWidget(),

                        // Graphique de température moyenne pour tout le rucher
                        _apiaries.isNotEmpty
                            ? SensorReadingsChart(
                                apiaryId: _apiaries.first.id,
                                showAverageTemperature: true,
                              )
                            : SensorReadingsChart(),

                        ThresholdEventsWidget(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHiveSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          value: _selectedHiveId,
          isExpanded: true,
          hint: const Text('Sélectionner une ruche'),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedHiveId = newValue;
              });
            }
          },
          items: _hives.map<DropdownMenuItem<String>>((Hive hive) {
            return DropdownMenuItem<String>(
              value: hive.id,
              child: Text(hive.name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNoHivesScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hive_outlined,
            size: 64,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune ruche disponible',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez une ruche pour commencer',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/apiaries');
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une ruche'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Initialisation des services...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Connexion à Firebase...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring IoT - Erreur'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Erreur de connexion',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Impossible de se connecter à Firebase après plusieurs tentatives. Vérifiez votre connexion internet et vos identifiants Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _timeoutExpired = false;
                    _isLoading = true;
                  });
                  _timeoutTimer?.cancel();
                  _timeoutTimer = Timer(const Duration(seconds: 10), () {
                    setState(() {
                      _timeoutExpired = true;
                    });
                  });
                  // Force rebuild to retry connection
                  Provider.of<SensorService>(context, listen: false)
                      .refreshAllData();
                  _loadInitialData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
