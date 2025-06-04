import 'package:flutter/foundation.dart';
import '../../models/hive.dart';
import '../../models/apiary.dart';
import '../../models/current_state.dart';
import '../../models/sensor_reading.dart';
import '../../models/threshold_event.dart';
import '../../models/time_filter.dart';
import '../../services/sensor_service.dart';
import 'sensor_repository.dart';

/// Implémentation concrète du repository utilisant SensorService
class SensorRepositoryImpl implements ISensorRepository {
  final SensorService _sensorService;

  SensorRepositoryImpl(this._sensorService);

  @override
  Future<List<Apiary>> getApiaries() async {
    try {
      return await _sensorService.getApiaries();
    } catch (e) {
      debugPrint('❌ Repository: Error getting apiaries: $e');
      return [];
    }
  }

  @override
  Future<List<Hive>> getHivesForApiary(String apiaryId) async {
    try {
      return await _sensorService.getHivesForApiary(apiaryId);
    } catch (e) {
      debugPrint('❌ Repository: Error getting hives for apiary $apiaryId: $e');
      return [];
    }
  }

  @override
  Future<Hive?> getHiveById(String hiveId) async {
    try {
      return await _sensorService.getHiveById(hiveId);
    } catch (e) {
      debugPrint('❌ Repository: Error getting hive $hiveId: $e');
      return null;
    }
  }

  @override
  Stream<CurrentState?> getCurrentState(String hiveId) {
    _sensorService.setCurrentHive(hiveId);
    return _sensorService.getCurrentState();
  }

  @override
  Stream<List<SensorReading>> getSensorReadings(
      String hiveId, TimeFilter timeFilter) {
    _sensorService.setCurrentHive(hiveId);
    _sensorService.setTimeFilter(timeFilter);
    return _sensorService.getSensorReadings();
  }

  @override
  Stream<List<ThresholdEvent>> getThresholdEvents(String hiveId) {
    _sensorService.setCurrentHive(hiveId);
    return _sensorService.getThresholdEvents();
  }

  @override
  Future<void> updateThresholds(
      String hiveId, double lowThreshold, double highThreshold) async {
    try {
      _sensorService.setCurrentHive(hiveId);
      await _sensorService.updateThresholds(lowThreshold, highThreshold);
    } catch (e) {
      debugPrint(
          '❌ Repository: Error updating thresholds for hive $hiveId: $e');
      rethrow;
    }
  }

  @override
  Future<void> refreshAllData() async {
    try {
      await _sensorService.refreshAllData();
    } catch (e) {
      debugPrint('❌ Repository: Error refreshing all data: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkConnection() async {
    try {
      final result = await _sensorService.checkDirectConnection();
      return result != null;
    } catch (e) {
      debugPrint('❌ Repository: Error checking connection: $e');
      return false;
    }
  }
}
