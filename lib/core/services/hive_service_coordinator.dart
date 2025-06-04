import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/current_state.dart';
import '../models/sensor_reading.dart';
import '../models/threshold_event.dart';
import '../models/time_filter.dart';
import '../models/apiary.dart';
import '../models/hive.dart';
import '../factories/service_factory.dart';
import '../config/app_config.dart';
import '../error/app_error.dart';

/// Coordinateur optimisé pour les services de ruche
/// Respecte le principe de responsabilité unique : coordination uniquement
class HiveServiceCoordinator {
  final FirebaseService _firebaseService;
  final CurrentStateService _currentStateService;
  final SensorReadingService _sensorReadingService;
  final ThresholdEventService _thresholdEventService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? _currentHiveId;
  String? get currentHiveId => _currentHiveId;

  bool get isConnected => _firebaseService.isConnected;

  HiveServiceCoordinator({
    required FirebaseService firebaseService,
    required CurrentStateService currentStateService,
    required SensorReadingService sensorReadingService,
    required ThresholdEventService thresholdEventService,
  })  : _firebaseService = firebaseService,
        _currentStateService = currentStateService,
        _sensorReadingService = sensorReadingService,
        _thresholdEventService = thresholdEventService;

  /// Initialise le coordinateur
  Future<void> initialize() async {
    try {
      if (!_firebaseService.isConnected) {
        await _firebaseService.initialize();
      }
      _isInitialized = true;
      debugPrint('✅ HiveServiceCoordinator initialized');
    } catch (e) {
      debugPrint('❌ Error initializing coordinator: $e');
      throw ServiceError(originalError: e);
    }
  }

  /// Définit la ruche active et configure tous les services
  Future<void> setActiveHive(String hiveId) async {
    if (!_isInitialized) {
      throw ServiceError(message: 'Coordinator not initialized');
    }

    _currentHiveId = hiveId;

    // Configurer tous les services pour cette ruche séquentiellement
    _currentStateService.setCurrentHive(hiveId);
    _sensorReadingService.setCurrentHive(hiveId);
    _thresholdEventService.setCurrentHive(hiveId);

    debugPrint('🐝 Active hive set to: $hiveId');
  }

  /// Récupère l'état actuel avec gestion d'erreur
  Stream<CurrentState?> getCurrentStateStream() {
    if (!_isValidated()) {
      return Stream.error(
        ServiceError(message: 'Service not properly configured'),
      );
    }
    return _currentStateService.stateStream;
  }

  /// Récupère les lectures de capteurs avec gestion d'erreur
  Stream<List<SensorReading>> getSensorReadingsStream() {
    if (!_isValidated()) {
      return Stream.error(
        ServiceError(message: 'Service not properly configured'),
      );
    }
    return _sensorReadingService.readingsStream;
  }

  /// Récupère les événements de seuil avec gestion d'erreur
  Stream<List<ThresholdEvent>> getThresholdEventsStream() {
    if (!_isValidated()) {
      return Stream.error(
        ServiceError(message: 'Service not properly configured'),
      );
    }
    return _thresholdEventService.eventsStream;
  }

  /// Change le filtre temporel
  Future<void> setTimeFilter(TimeFilter filter) async {
    if (!_isValidated()) {
      throw ServiceError(message: 'Service not properly configured');
    }

    await _sensorReadingService.setTimeFilter(filter);
  }

  /// Met à jour les seuils de température
  Future<void> updateThresholds(
      double lowThreshold, double highThreshold) async {
    if (!_isValidated()) {
      throw ServiceError(message: 'Service not properly configured');
    }

    // Validation des seuils
    if (lowThreshold < AppConfig.minTemperature ||
        highThreshold > AppConfig.maxTemperature ||
        lowThreshold >= highThreshold) {
      throw ValidationError(message: 'Seuils de température invalides');
    }

    final updateData = {
      'hysteresis': {
        'temperature': {
          'threshold': highThreshold,
          'upper_offset': AppConfig.defaultHysteresisOffset,
          'lower_offset': AppConfig.defaultHysteresisOffset
        }
      }
    };

    try {
      await _firebaseService.updateData(
        'hives/$_currentHiveId/current_state',
        updateData,
      );

      // Rafraîchir l'état
      await _currentStateService.getCurrentState();

      debugPrint('✅ Thresholds updated for hive $_currentHiveId');
    } catch (e) {
      debugPrint('❌ Error updating thresholds: $e');
      throw FirebaseError(originalError: e);
    }
  }

  /// Vérifie la connexion et récupère un état de base
  Future<Map<String, dynamic>?> checkConnectionStatus() async {
    try {
      final isConnected = await _firebaseService.checkDirectConnection();

      if (!isConnected || _currentHiveId == null) {
        return null;
      }

      final state = await _currentStateService.getCurrentState();
      if (state == null) return null;

      return {
        'connection': 'ok',
        'hive_id': _currentHiveId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      debugPrint('❌ Error checking connection: $e');
      return null;
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refreshAllData() async {
    if (!_isValidated()) {
      throw ServiceError(message: 'Service not properly configured');
    }

    try {
      // Rafraîchir l'état actuel seulement (les autres services n'ont pas de refresh)
      await _currentStateService.getCurrentState();

      debugPrint('✅ All data refreshed for hive $_currentHiveId');
    } catch (e) {
      debugPrint('❌ Error refreshing data: $e');
      throw ServiceError(originalError: e);
    }
  }

  /// Récupère tous les ruchers - données mock pour le moment
  Future<List<Apiary>> getApiaries() async {
    // Pour l'instant, retourner des données mock
    final now = DateTime.now();
    return [
      Apiary(
        id: 'apiary_1',
        name: 'Rucher Principal',
        location: 'Jardin',
        createdAt: now,
        updatedAt: now,
        hiveIds: ['hive_1', 'hive_2'],
      ),
    ];
  }

  /// Récupère les ruches d'un rucher - données mock pour le moment
  Future<List<Hive>> getHivesForApiary(String apiaryId) async {
    // Pour l'instant, retourner des données mock
    final now = DateTime.now();
    return [
      Hive(
        id: 'hive_1',
        name: 'Ruche Alpha',
        apiaryId: apiaryId,
        createdAt: now,
        updatedAt: now,
        recentReadings: [],
      ),
      Hive(
        id: 'hive_2',
        name: 'Ruche Beta',
        apiaryId: apiaryId,
        createdAt: now,
        updatedAt: now,
        recentReadings: [],
      ),
    ];
  }

  /// Validation interne
  bool _isValidated() {
    return _isInitialized && _currentHiveId != null;
  }

  /// Nettoyage des ressources
  void dispose() {
    // Le coordinateur ne possède pas les services, il ne les dispose pas
    debugPrint('🧹 HiveServiceCoordinator disposed');
  }
}
