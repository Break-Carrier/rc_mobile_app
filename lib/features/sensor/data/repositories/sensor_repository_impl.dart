import 'package:flutter/foundation.dart';
import '../../domain/entities/hive.dart';
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
  final HiveServiceCoordinator _coordinator;
  final FirebaseService _firebaseService;

  SensorRepositoryImpl(this._coordinator)
      : _firebaseService = ServiceFactory.firebaseService;

  @override
  Future<List<Apiary>> getApiaries() async {
    try {
      return _coordinator.getApiaries();
    } catch (e) {
      debugPrint('❌ Repository: Error getting apiaries: $e');
      return [];
    }
  }

  @override
  Future<List<Hive>> getHivesForApiary(String apiaryId) async {
    try {
      await _firebaseService.initialize();

      // Récupérer toutes les ruches depuis Firebase
      final data = await _firebaseService.getData('hives');
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
    try {
      await _firebaseService.initialize();

      // Récupérer directement la ruche depuis Firebase
      final data = await _firebaseService.getData('hives/$hiveId');
      if (data == null) return null;

      final hive = Hive.fromFirebase(data as Map<String, dynamic>, hiveId);
      debugPrint('✅ Repository: Retrieved hive $hiveId from Firebase');
      return hive;
    } catch (e) {
      debugPrint('❌ Repository: Error getting hive $hiveId: $e');
      return null;
    }
  }

  @override
  Stream<CurrentState?> getCurrentState(String hiveId) {
    _coordinator.setActiveHive(hiveId);
    return _coordinator.getCurrentStateStream();
  }

  @override
  Stream<List<SensorReading>> getSensorReadings(
      String hiveId, TimeFilter timeFilter) {
    _coordinator.setActiveHive(hiveId);
    _coordinator.setTimeFilter(timeFilter);
    return _coordinator.getSensorReadingsStream();
  }

  @override
  Stream<List<ThresholdEvent>> getThresholdEvents(String hiveId) {
    _coordinator.setActiveHive(hiveId);
    return _coordinator.getThresholdEventsStream();
  }

  @override
  Future<void> updateThresholds(
      String hiveId, double lowThreshold, double highThreshold) async {
    try {
      await _coordinator.setActiveHive(hiveId);
      await _coordinator.updateThresholds(lowThreshold, highThreshold);
    } catch (e) {
      debugPrint(
          '❌ Repository: Error updating thresholds for hive $hiveId: $e');
      rethrow;
    }
  }

  @override
  Future<void> refreshAllData() async {
    try {
      await _coordinator.refreshAllData();
    } catch (e) {
      debugPrint('❌ Repository: Error refreshing all data: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkConnection() async {
    try {
      final result = await _coordinator.checkConnectionStatus();
      return result != null;
    } catch (e) {
      debugPrint('❌ Repository: Error checking connection: $e');
      return false;
    }
  }
}
