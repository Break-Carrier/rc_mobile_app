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

  /// Teste la connexion à Firebase
  Future<Map<String, dynamic>?> checkDirectConnection() async {
    try {
      final isConnected = await _firebaseService.checkDirectConnection();

      if (isConnected && _currentStateService != null) {
        // Récupérer l'état actuel
        final state = await _currentStateService!.getCurrentState();

        if (state != null) {
          return {
            'temperature': state.temperature,
            'humidity': state.humidity,
            'last_update': state.timestamp.millisecondsSinceEpoch,
            'threshold_high': state.thresholdHigh,
            'threshold_low': state.thresholdLow,
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
    if (!_areServicesReady()) {
      // Si les services ne sont pas prêts, retourner un stream vide
      return Stream.value(null);
    }
    return _currentStateService!.stateStream;
  }

  /// Récupère les lectures de capteurs
  Stream<List<SensorReading>> getSensorReadings() {
    if (!_areServicesReady()) {
      // Si les services ne sont pas prêts, retourner un stream avec une liste vide
      return Stream.value([]);
    }
    return _sensorReadingService!.readingsStream;
  }

  /// Récupère les événements de dépassement de seuil
  Stream<List<ThresholdEvent>> getThresholdEvents() {
    if (!_areServicesReady()) {
      // Si les services ne sont pas prêts, retourner un stream avec une liste vide
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
    if (!_areServicesReady()) {
      debugPrint('❌ Services not initialized, cannot update thresholds');
      return;
    }

    // Enregistrer l'état actuel avant la mise à jour
    final currentState = _currentStateService!.currentState;
    final oldHighThreshold = currentState?.thresholdHigh;
    final oldLowThreshold = currentState?.thresholdLow;
    final temperature = currentState?.temperature;

    // Mettre à jour les seuils
    await _currentStateService!.updateThresholds(lowThreshold, highThreshold);

    // Récupérer l'état actualisé après la mise à jour
    final updatedState = _currentStateService!.currentState;

    if (updatedState != null && temperature != null) {
      // Déterminer le type d'événement si nécessaire
      ThresholdEventType? eventType;

      // Si la température dépasse maintenant le seuil, mais pas avant
      if (oldHighThreshold != null && oldLowThreshold != null) {
        bool wasOverThresholdBefore =
            temperature > oldHighThreshold || temperature < oldLowThreshold;
        bool isOverThresholdNow =
            temperature > highThreshold || temperature < lowThreshold;

        // Si le statut de dépassement a changé suite à la modification des seuils
        if (!wasOverThresholdBefore && isOverThresholdNow) {
          // Déterminer quel seuil est dépassé
          if (temperature > highThreshold) {
            eventType = ThresholdEventType.exceeded;
            debugPrint(
                '🚨 Threshold crossed due to threshold change: Temperature exceeds new high threshold');
          } else if (temperature < lowThreshold) {
            eventType = ThresholdEventType.exceeded;
            debugPrint(
                '🚨 Threshold crossed due to threshold change: Temperature below new low threshold');
          }
        }
      }

      // Créer un événement si nécessaire
      if (eventType != null) {
        await _thresholdEventService!.createThresholdEvent(
          temperature: temperature,
          humidity: updatedState.humidity,
          eventType: eventType,
          thresholdHigh: highThreshold,
          thresholdLow: lowThreshold,
        );
      }
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refreshAllData() async {
    if (!_areServicesReady()) {
      debugPrint('❌ Services not initialized, cannot refresh data');
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
    if (!_areServicesReady()) {
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
          apiaries.add(Apiary.fromFirestore(value, key));
        }
      });

      return apiaries;
    } catch (e) {
      debugPrint('❌ Error fetching apiaries: $e');
      return [];
    }
  }

  /// Récupère toutes les ruches d'un rucher
  Future<List<Hive>> getHivesByApiary(String apiaryId) async {
    if (!_areServicesReady()) {
      return [];
    }

    try {
      final data = await _firebaseService.getData('hives');

      if (data == null || data.isEmpty) {
        debugPrint('⚠️ No hives found');
        return [];
      }

      final hives = <Hive>[];
      data.forEach((key, value) {
        if (value is Map<String, dynamic> && value['apiary_id'] == apiaryId) {
          hives.add(Hive.fromFirestore(value, key));
        }
      });

      return hives;
    } catch (e) {
      debugPrint('❌ Error fetching hives for apiary $apiaryId: $e');
      return [];
    }
  }

  /// Récupère une ruche par son ID
  Future<Hive?> getHive(String hiveId) async {
    if (!_areServicesReady()) {
      return null;
    }

    try {
      final data = await _firebaseService.getData('hives/$hiveId');

      if (data == null) {
        debugPrint('⚠️ Hive $hiveId not found');
        return null;
      }

      return Hive.fromFirestore(data, hiveId);
    } catch (e) {
      debugPrint('❌ Error fetching hive $hiveId: $e');
      return null;
    }
  }

  /// Récupère les lectures actuelles des capteurs pour une ruche donnée
  Stream<List<SensorReading>> getCurrentReadings(String hiveId) {
    if (!_areServicesReady()) {
      return Stream.value([]);
    }

    return _firebaseService.getDataStream('sensor_readings').map((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = MapConverter.convertToStringDynamicMap(
            event.snapshot.value as Map<Object?, Object?>);

        final readings = <SensorReading>[];
        data.forEach((key, value) {
          if (value is Map<String, dynamic> && value['sensorId'] == hiveId) {
            readings.add(SensorReading.fromRealtimeDB(value, key));
          }
        });

        // Trier par timestamp (plus récent en premier)
        readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Limiter les résultats
        if (readings.length > 10) {
          readings.length = 10;
        }

        return readings;
      }
      return <SensorReading>[];
    });
  }

  /// Ajoute une nouvelle lecture de capteur
  Future<void> addReading(SensorReading reading) async {
    if (!_areServicesReady()) {
      debugPrint('❌ Services not initialized, cannot add reading');
      return;
    }

    // Ajouter la lecture à la collection de lectures
    await _firebaseService.pushData(
        'sensor_readings', reading.toRealtimeDBMap());

    // Mettre à jour l'état actuel de la ruche
    if (reading.type == 'temperature' || reading.type == 'humidity') {
      final hiveData =
          await _firebaseService.getData('hives/${reading.sensorId}');

      if (hiveData != null) {
        final currentState =
            hiveData['current_state'] as Map<String, dynamic>? ?? {};

        if (reading.type == 'temperature') {
          currentState['temperature'] = reading.value;
        } else if (reading.type == 'humidity') {
          currentState['humidity'] = reading.value;
        }

        currentState['timestamp'] = reading.timestamp.millisecondsSinceEpoch;

        await _firebaseService.updateData('hives/${reading.sensorId}', {
          'current_state': currentState,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  /// Récupère l'historique des lectures pour une période donnée
  Future<List<SensorReading>> getReadingsHistory(
      String hiveId, DateTime start, DateTime end) async {
    if (!_areServicesReady()) {
      return [];
    }

    try {
      final data = await _firebaseService.getData('sensor_readings');

      if (data == null || data.isEmpty) {
        return [];
      }

      final readings = <SensorReading>[];
      data.forEach((key, value) {
        if (value is Map<String, dynamic> && value['sensorId'] == hiveId) {
          final reading = SensorReading.fromRealtimeDB(value, key);
          if (reading.timestamp.isAfter(start) &&
              reading.timestamp.isBefore(end)) {
            readings.add(reading);
          }
        }
      });

      // Trier par timestamp (plus récent en premier)
      readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return readings;
    } catch (e) {
      debugPrint('❌ Error fetching readings history: $e');
      return [];
    }
  }

  /// Récupère les événements de seuil pour une ruche donnée
  Future<List<ThresholdEvent>> getThresholdEventsForHive(String hiveId) async {
    if (!_areServicesReady()) {
      return [];
    }

    try {
      final data = await _firebaseService.getData('threshold_events');

      if (data == null || data.isEmpty) {
        return [];
      }

      final events = <ThresholdEvent>[];
      data.forEach((key, value) {
        if (value is Map<String, dynamic> && value['hive_id'] == hiveId) {
          events.add(ThresholdEvent.fromRealtimeDB(value, key));
        }
      });

      // Trier par timestamp (plus récent en premier)
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return events;
    } catch (e) {
      debugPrint('❌ Error fetching threshold events: $e');
      return [];
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
