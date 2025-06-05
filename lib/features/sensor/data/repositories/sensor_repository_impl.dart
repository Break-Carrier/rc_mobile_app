import 'package:flutter/foundation.dart';
import '../../domain/entities/hive.dart';
import '../../domain/entities/apiary.dart';
import '../../domain/entities/current_state.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/entities/threshold_event.dart';
import '../../domain/entities/time_filter.dart';
import '../../../../core/services/hive_service_coordinator.dart';
import '../../domain/repositories/sensor_repository.dart';

/// Implémentation concrète du repository utilisant HiveServiceCoordinator
class SensorRepositoryImpl implements ISensorRepository {
  final HiveServiceCoordinator _coordinator;

  SensorRepositoryImpl(this._coordinator);

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
      return _coordinator.getHivesForApiary(apiaryId);
    } catch (e) {
      debugPrint('❌ Repository: Error getting hives for apiary $apiaryId: $e');
      return [];
    }
  }

  @override
  Future<Hive?> getHiveById(String hiveId) async {
    try {
      // Pour l'instant, on récupère toutes les ruches et on filtre
      final apiaries = await _coordinator.getApiaries();
      for (final apiary in apiaries) {
        final hives = await _coordinator.getHivesForApiary(apiary.id);
        for (final hive in hives) {
          if (hive.id == hiveId) {
            return hive;
          }
        }
      }
      return null;
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
