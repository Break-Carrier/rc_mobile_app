import 'package:flutter/foundation.dart';
import '../../domain/entities/hive.dart';
import '../../domain/entities/hive_sensor_data.dart';
import '../../domain/entities/apiary.dart';
import '../../domain/entities/current_state.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/entities/threshold_event.dart';
import '../../domain/entities/time_filter.dart';
import '../../../../core/services/hive_service_coordinator.dart';
import '../../../../core/factories/service_factory.dart';
import '../../domain/repositories/sensor_repository.dart';

/// Implémentation concrète du repository utilisant HiveServiceCoordinator
class SensorRepositoryImpl implements ISensorRepository {
  final HiveServiceCoordinator? _coordinator;
  final FirebaseService? _firebaseService;

  SensorRepositoryImpl(this._coordinator, this._firebaseService);

  @override
  Future<List<Apiary>> getApiaries() async {
    if (_coordinator == null) return [];
    try {
      return _coordinator!.getApiaries();
    } catch (e) {
      debugPrint('❌ Repository: Error getting apiaries: $e');
      return [];
    }
  }

  @override
  Future<List<Hive>> getHivesForApiary(String apiaryId) async {
    if (_firebaseService == null) return [];
    try {
      await _firebaseService!.initialize();

      // Récupérer toutes les ruches depuis Firebase
      final data = await _firebaseService!.getData('hives');
      if (data == null) return [];

      final List<Hive> hives = [];

      // Parcourir les données Firebase et créer les objets Hive
      (data as Map<String, dynamic>).forEach((hiveId, hiveData) {
        if (hiveData is Map<String, dynamic>) {
          final hive = Hive.fromFirebase(hiveData, hiveId);
          // Filtrer par apiaryId si nécessaire (pour l'instant on récupère toutes les ruches)
          hives.add(hive);
        }
      });

      debugPrint('✅ Repository: Retrieved ${hives.length} hives from Firebase');
      return hives;
    } catch (e) {
      debugPrint('❌ Repository: Error getting hives for apiary $apiaryId: $e');
      return [];
    }
  }

  @override
  Future<Hive?> getHiveById(String hiveId) async {
    if (_firebaseService == null) return null;
    try {
      await _firebaseService!.initialize();

      // Récupérer directement la ruche depuis Firebase
      final data = await _firebaseService!.getData('hives/$hiveId');
      if (data == null) return null;

      final hive = Hive.fromFirebase(data as Map<String, dynamic>, hiveId);

      // Si la ruche n'a pas de données de capteurs, ajouter des données simulées pour le test
      if (hive.sensorData == null) {
        final simulatedSensorData = _generateMockSensorData(hiveId);
        final hiveWithSensorData =
            hive.copyWith(sensorData: simulatedSensorData);
        debugPrint(
            '✅ Repository: Retrieved hive $hiveId from Firebase with simulated sensor data');
        return hiveWithSensorData;
      }

      debugPrint('✅ Repository: Retrieved hive $hiveId from Firebase');
      return hive;
    } catch (e) {
      debugPrint('❌ Repository: Error getting hive $hiveId: $e');
      return null;
    }
  }

  @override
  Stream<CurrentState?> getCurrentState(String hiveId) {
    if (_coordinator == null) return Stream.value(null);
    _coordinator!.setActiveHive(hiveId);
    return _coordinator!.getCurrentStateStream();
  }

  @override
  Stream<List<SensorReading>> getSensorReadings(
      String hiveId, TimeFilter timeFilter) {
    // Pour le moment, retourner des données mockées
    // TODO: Implémenter la récupération depuis Firebase quand les données seront disponibles
    final mockReadings = _generateMockSensorHistory(hiveId);
    return Stream.value(mockReadings);
  }

  /// Récupère l'historique des capteurs sur 7 heures (données mockées)
  Future<List<SensorReading>> getSensorHistory(String hiveId) async {
    return _generateMockSensorHistory(hiveId);
  }

  /// Génère des données de capteurs mockées réalistes
  HiveSensorData _generateMockSensorData(String hiveId) {
    final now = DateTime.now();
    final baseTemp = 22.0 + (hiveId.hashCode % 8); // 22-30°C
    final baseHumidity = 45.0 + (hiveId.hashCode % 25); // 45-70%

    // Simulation d'une variation diurne
    final hour = now.hour;
    final tempVariation = (hour - 12) * 0.5; // Plus chaud l'après-midi
    final humidityVariation =
        (hour < 6 || hour > 18) ? 10 : -5; // Plus humide la nuit

    return HiveSensorData(
      temperature: (baseTemp + tempVariation + (hiveId.hashCode % 3) - 1)
          .clamp(18.0, 35.0),
      humidity: (baseHumidity + humidityVariation + (hiveId.hashCode % 5) - 2)
          .clamp(30.0, 85.0),
      coverState:
          (hiveId.hashCode % 2) == 0 ? CoverState.open : CoverState.closed,
      ledState: (hiveId.hashCode % 3) == 0 ? LedState.on : LedState.off,
    );
  }

  /// Génère un historique de données de capteurs sur 7 heures
  List<SensorReading> _generateMockSensorHistory(String hiveId) {
    final now = DateTime.now();
    final readings = <SensorReading>[];

    // Générer des données toutes les 30 minutes sur 7 heures (14 points)
    for (int i = 0; i < 14; i++) {
      final timestamp = now.subtract(Duration(hours: 6, minutes: 30 * i));
      final hour = timestamp.hour;

      // Simulation réaliste avec variation diurne
      final baseTemp = 22.0 + (hiveId.hashCode % 8);
      final tempVariation = (hour - 12) * 0.3; // Variation diurne
      final randomTemp = (hiveId.hashCode + i) % 3 - 1; // Variation aléatoire

      final baseHumidity = 45.0 + (hiveId.hashCode % 25);
      final humidityVariation =
          (hour < 6 || hour > 18) ? 8 : -3; // Plus humide la nuit
      final randomHumidity =
          (hiveId.hashCode + i * 2) % 5 - 2; // Variation aléatoire

      final temperature =
          (baseTemp + tempVariation + randomTemp).clamp(18.0, 35.0);
      final humidity =
          (baseHumidity + humidityVariation + randomHumidity).clamp(30.0, 85.0);

      readings.add(SensorReading(
        id: 'mock_${hiveId}_$i',
        hiveId: hiveId,
        temperature: temperature,
        humidity: humidity,
        timestamp: timestamp,
        metadata: {'source': 'mock', 'index': i},
      ));
    }

    return readings.reversed.toList(); // Plus récent en premier
  }

  @override
  Stream<List<ThresholdEvent>> getThresholdEvents(String hiveId) {
    if (_coordinator == null) return Stream.value([]);
    _coordinator!.setActiveHive(hiveId);
    return _coordinator!.getThresholdEventsStream();
  }

  @override
  Future<void> updateThresholds(
      String hiveId, double lowThreshold, double highThreshold) async {
    if (_coordinator == null) return;
    try {
      await _coordinator!.setActiveHive(hiveId);
      await _coordinator!.updateThresholds(lowThreshold, highThreshold);
    } catch (e) {
      debugPrint(
          '❌ Repository: Error updating thresholds for hive $hiveId: $e');
      rethrow;
    }
  }

  @override
  Future<void> refreshAllData() async {
    if (_coordinator == null) return;
    try {
      await _coordinator!.refreshAllData();
    } catch (e) {
      debugPrint('❌ Repository: Error refreshing all data: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkConnection() async {
    if (_coordinator == null) return false;
    try {
      final result = await _coordinator!.checkConnectionStatus();
      return result != null;
    } catch (e) {
      debugPrint('❌ Repository: Error checking connection: $e');
      return false;
    }
  }
}
