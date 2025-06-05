import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/widgets/chart/sensor_chart.dart';
import '../core/widgets/events/threshold_events.dart';
import '../core/widgets/state/state_stream_widget.dart';
import '../core/widgets/threshold/threshold_config.dart';
import '../core/factories/service_factory.dart';
import '../features/sensor/domain/entities/hive.dart';
import '../features/sensor/domain/entities/apiary.dart';
import '../features/auth/presentation/bloc/auth_navigation_bloc.dart';

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

  late final coordinator = ServiceFactory.getHiveServiceCoordinator();

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
    try {
      if (coordinator.isInitialized) {
        // Récupérer les ruchers
        _apiaries = await coordinator.getApiaries();

        if (_apiaries.isNotEmpty) {
          // Récupérer les ruches du premier rucher
          _hives = await coordinator.getHivesForApiary(_apiaries.first.id);

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
      }
    } catch (e) {
      debugPrint('❌ Error loading initial data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si le timeout a expiré et services toujours pas initialisés
    if (_timeoutExpired && !coordinator.isInitialized) {
      return _buildErrorScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruches'),
        actions: [
          // Bouton d'ajout
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implémenter l'ajout d'une ruche
            },
          ),

          // Menu de navigation clean
          PopupMenuButton<String>(
            onSelected: (value) {
              final authNavBloc = context.read<AuthNavigationBloc>();

              switch (value) {
                case 'auth_info':
                  authNavBloc.add(const NavigateToAuthInfoRequested());
                  break;
                case 'logout':
                  authNavBloc.add(const ShowLogoutDialogRequested());
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'auth_info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Informations d\'authentification'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Déconnexion'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: !coordinator.isInitialized || _isLoading
          ? _buildLoadingScreen()
          : _selectedHiveId == null
              ? _buildNoHivesScreen()
              : RefreshIndicator(
                  onRefresh: () async {
                    // Rafraîchir toutes les données lors d'un swipe vers le bas
                    try {
                      await coordinator.refreshAllData();
                      await _loadInitialData();
                    } catch (e) {
                      debugPrint('❌ Error refreshing data: $e');
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sélecteur de ruche
                        if (_hives.length > 1) _buildHiveSelector(),

                        // État actuel avec le nouveau widget optimisé
                        StateStreamWidget(
                          hiveId: _selectedHiveId!,
                          onRefresh: () async {
                            await coordinator.refreshAllData();
                            await _loadInitialData();
                          },
                        ),

                        const ThresholdConfig(),

                        // Graphique de température moyenne pour tout le rucher
                        _apiaries.isNotEmpty
                            ? SensorChart(
                                apiaryId: _apiaries.first.id,
                                showAverageTemperature: true,
                              )
                            : const SensorChart(),

                        const ThresholdEvents(),
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
              // TODO: Implémenter la navigation vers la page des ruchers
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
          Text('Initialisation en cours...'),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Erreur d\'initialisation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les services n\'ont pas pu être initialisés',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Relancer l'initialisation
              setState(() {
                _timeoutExpired = false;
                _isLoading = true;
              });
              _timeoutTimer = Timer(const Duration(seconds: 10), () {
                setState(() {
                  _timeoutExpired = true;
                });
              });
              _loadInitialData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
