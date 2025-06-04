import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/current_state.dart';
import '../../models/sensor_reading.dart';
import '../../models/threshold_event.dart';
import '../../models/time_filter.dart';
import '../../models/apiary.dart';
import '../../models/hive.dart';
import '../../services/firebase_service.dart';
import '../../services/current_state_service.dart';
import '../../services/sensor_reading_service.dart';
import '../../services/threshold_event_service.dart';
import '../../services/sensor_service.dart';
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
        'temperature': state.temperature,
        'humidity': state.humidity,
        'last_update': state.timestamp.millisecondsSinceEpoch,
        'is_over_threshold': state.isOverThreshold,
        'hive_id': _currentHiveId,
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

  /// Récupère tous les ruchers (temporaire - utilise l'ancien service)
  Future<List<Apiary>> getApiaries() async {
    // TODO: Implémenter avec un repository dédié
    // Pour l'instant, on utilise une instance temporaire de l'ancien service
    final tempService = SensorService();
    if (!tempService.isInitialized) {
      // Attendre l'initialisation
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return !tempService.isInitialized;
      });
    }
    return await tempService.getApiaries();
  }

  /// Récupère les ruches d'un rucher (temporaire - utilise l'ancien service)
  Future<List<Hive>> getHivesForApiary(String apiaryId) async {
    // TODO: Implémenter avec un repository dédié
    final tempService = SensorService();
    if (!tempService.isInitialized) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return !tempService.isInitialized;
      });
    }
    return await tempService.getHivesForApiary(apiaryId);
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
