import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/current_state.dart';
import '../models/sensor_reading.dart';
import '../models/threshold_event.dart';
import '../models/time_filter.dart';
import '../models/apiary.dart';
import '../models/hive.dart';
import '../utils/map_converter.dart';
import 'firebase_service.dart';
import 'current_state_service.dart';
import 'sensor_reading_service.dart';
import 'threshold_event_service.dart';

/// Service principal qui coordonne tous les services de capteurs
class SensorService extends ChangeNotifier {
  final FirebaseService _firebaseService;
  CurrentStateService? _currentStateService;
  SensorReadingService? _sensorReadingService;
  ThresholdEventService? _thresholdEventService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Cache pour l'état actuel
  CurrentState? _lastKnownState;
  CurrentState? get lastKnownState => _lastKnownState;

  /// Filtre temporel actuel
  TimeFilter _currentTimeFilter = TimeFilter.oneHour;
  TimeFilter get currentTimeFilter => _currentTimeFilter;

  /// État de connexion
  bool get isConnected => _firebaseService.isConnected;

  /// Ruche actuellement active
  String? _currentHiveId;
  String? get currentHiveId => _currentHiveId;

  /// Constructeur
  SensorService() : _firebaseService = FirebaseService() {
    _initializeServices();
  }

  /// Initialise tous les services
  Future<void> _initializeServices() async {
    try {
      // Initialiser le service Firebase
      await _firebaseService.initialize();

      // Initialiser les services spécialisés
      _currentStateService = CurrentStateService(_firebaseService);
      _sensorReadingService = SensorReadingService(_firebaseService);
      _thresholdEventService = ThresholdEventService(_firebaseService);

      // Écouter l'état actuel
      _currentStateService?.stateStream.listen((state) {
        _lastKnownState = state;
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
      debugPrint('✅ All sensor services initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing sensor services: $e');
      // Essayer d'initialiser avec ce qui a fonctionné
      _isInitialized = _currentStateService != null &&
          _sensorReadingService != null &&
          _thresholdEventService != null;
      notifyListeners();
    }
  }

  /// Vérifie si les services sont prêts
  bool _areServicesReady() {
    return _isInitialized &&
        _currentStateService != null &&
        _sensorReadingService != null &&
        _thresholdEventService != null;
  }

  /// Définir la ruche active
  void setCurrentHive(String hiveId) {
    _currentHiveId = hiveId;
    if (_areServicesReady()) {
      _currentStateService?.setCurrentHive(hiveId);
      _sensorReadingService?.setCurrentHive(hiveId);
      _thresholdEventService?.setCurrentHive(hiveId);
    }
    notifyListeners();
    debugPrint('🐝 Current hive set to: $hiveId');
  }

  /// Teste la connexion à Firebase
  Future<Map<String, dynamic>?> checkDirectConnection() async {
    try {
      final isConnected = await _firebaseService.checkDirectConnection();

      if (isConnected &&
          _currentStateService != null &&
          _currentHiveId != null) {
        // Récupérer l'état actuel
        final state = await _currentStateService!.getCurrentState();

        if (state != null) {
          return {
            'temperature': state.temperature,
            'humidity': state.humidity,
            'last_update': state.timestamp.millisecondsSinceEpoch,
            'is_over_threshold': state.isOverThreshold,
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error checking direct connection: $e');
      return null;
    }
  }

  /// Récupère l'état actuel des capteurs
  Stream<CurrentState?> getCurrentState() {
    if (!_areServicesReady() || _currentHiveId == null) {
      // Si les services ne sont pas prêts ou aucune ruche sélectionnée, retourner un stream vide
      return Stream.value(null);
    }
    return _currentStateService!.stateStream;
  }

  /// Récupère les lectures de capteurs
  Stream<List<SensorReading>> getSensorReadings() {
    if (!_areServicesReady() || _currentHiveId == null) {
      // Si les services ne sont pas prêts ou aucune ruche sélectionnée, retourner un stream avec une liste vide
      return Stream.value([]);
    }
    return _sensorReadingService!.readingsStream;
  }

  /// Récupère les événements de dépassement de seuil
  Stream<List<ThresholdEvent>> getThresholdEvents() {
    if (!_areServicesReady() || _currentHiveId == null) {
      // Si les services ne sont pas prêts ou aucune ruche sélectionnée, retourner un stream avec une liste vide
      return Stream.value([]);
    }
    return _thresholdEventService!.eventsStream;
  }

  /// Modifie le filtre temporel pour les lectures de capteurs
  Future<void> setTimeFilter(TimeFilter filter) async {
    _currentTimeFilter = filter;
    if (_areServicesReady()) {
      await _sensorReadingService!.setTimeFilter(filter);
    }
    notifyListeners();
  }

  /// Met à jour les seuils de température
  Future<void> updateThresholds(
      double lowThreshold, double highThreshold) async {
    if (!_areServicesReady() || _currentHiveId == null) {
      debugPrint(
          '❌ Services not initialized or no hive selected, cannot update thresholds');
      return;
    }

    // Enregistrer l'état actuel avant la mise à jour
    final currentState = _currentStateService!.currentState;
    final temperature = currentState?.temperature;

    // Mettre à jour les seuils dans la structure de hysteresis
    final updateData = {
      'hysteresis': {
        'temperature': {
          'threshold': highThreshold,
          'upper_offset': 0.5,
          'lower_offset': 0.5
        }
      }
    };

    try {
      // Mettre à jour dans la structure de current_state
      await _firebaseService.updateData(
          'hives/$_currentHiveId/current_state', updateData);
      debugPrint('✅ Threshold updated successfully for hive $_currentHiveId');

      // Rafraîchir l'état
      await _currentStateService!.getCurrentState();
    } catch (e) {
      debugPrint('❌ Error updating thresholds: $e');
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refreshAllData() async {
    if (!_areServicesReady() || _currentHiveId == null) {
      debugPrint(
          '❌ Services not initialized or no hive selected, cannot refresh data');
      return;
    }

    try {
      await Future.wait([
        _currentStateService!.getCurrentState(),
        _sensorReadingService!.getSensorReadings(),
        _thresholdEventService!.getThresholdEvents(),
      ]);

      debugPrint('✅ All data refreshed successfully');
    } catch (e) {
      debugPrint('❌ Error refreshing all data: $e');
    }
  }

  /// Récupère tous les ruchers
  Future<List<Apiary>> getApiaries() async {
    if (!_isInitialized) {
      return [];
    }

    try {
      final data = await _firebaseService.getData('apiaries');

      if (data == null || data.isEmpty) {
        debugPrint('⚠️ No apiaries found');
        return [];
      }

      final apiaries = <Apiary>[];
      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            final apiary = Apiary.fromFirestore(value, key);
            apiaries.add(apiary);
          } catch (e) {
            debugPrint('❌ Error parsing apiary $key: $e');
          }
        }
      });

      debugPrint('📊 Found ${apiaries.length} apiaries');
      return apiaries;
    } catch (e) {
      debugPrint('❌ Error fetching apiaries: $e');
      return [];
    }
  }

  /// Récupère toutes les ruches d'un rucher
  Future<List<Hive>> getHivesForApiary(String apiaryId) async {
    if (!_isInitialized) {
      return [];
    }

    try {
      // D'abord récupérer les IDs des ruches pour ce rucher
      final apiaryData = await _firebaseService.getData('apiaries/$apiaryId');

      if (apiaryData == null || !apiaryData.containsKey('hive_ids')) {
        debugPrint('⚠️ No hive IDs found for apiary $apiaryId');
        return [];
      }

      final hiveIds = List<String>.from(apiaryData['hive_ids'] ?? []);
      final hives = <Hive>[];

      // Récupérer les données de chaque ruche
      for (final hiveId in hiveIds) {
        try {
          final hiveData = await _firebaseService.getData('hives/$hiveId');

          if (hiveData != null) {
            // Assignation correct de l'apiary_id
            hiveData['apiary_id'] = apiaryId;
            final hive = Hive.fromFirestore(hiveData, hiveId);
            hives.add(hive);
          }
        } catch (e) {
          debugPrint('❌ Error fetching hive $hiveId: $e');
        }
      }

      debugPrint('📊 Found ${hives.length} hives for apiary $apiaryId');
      return hives;
    } catch (e) {
      debugPrint('❌ Error fetching hives for apiary $apiaryId: $e');
      return [];
    }
  }

  /// Récupère une ruche par son ID
  Future<Hive?> getHiveById(String hiveId) async {
    if (!_isInitialized) {
      return null;
    }

    try {
      final hiveData = await _firebaseService.getData('hives/$hiveId');

      if (hiveData == null) {
        debugPrint('⚠️ No hive found with ID $hiveId');
        return null;
      }

      // Rechercher à quel rucher appartient cette ruche
      final apiaries = await getApiaries();
      String? apiaryId;

      for (final apiary in apiaries) {
        if (apiary.hiveIds.contains(hiveId)) {
          apiaryId = apiary.id;
          break;
        }
      }

      if (apiaryId == null) {
        debugPrint('⚠️ Hive $hiveId does not belong to any apiary');
        return null;
      }

      // Assigner l'ID du rucher
      hiveData['apiary_id'] = apiaryId;
      return Hive.fromFirestore(hiveData, hiveId);
    } catch (e) {
      debugPrint('❌ Error fetching hive $hiveId: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _currentStateService?.dispose();
    _sensorReadingService?.dispose();
    _thresholdEventService?.dispose();
    _firebaseService.dispose();
    super.dispose();
  }
}
