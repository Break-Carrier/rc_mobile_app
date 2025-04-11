import 'package:flutter/foundation.dart';
import '../../../../models/hive.dart';
import '../../../../models/current_state.dart';
import '../../../../models/sensor_reading.dart';
import '../../../../models/threshold_event.dart';
import '../../../../models/time_filter.dart';
import '../../../../services/sensor_service.dart';
import '../../domain/repositories/hive_repository_interface.dart';

/// Implémentation du repository pour les ruches qui utilise SensorService
class HiveRepository implements IHiveRepository {
  final SensorService _sensorService;

  HiveRepository({SensorService? sensorService})
      : _sensorService = sensorService ?? SensorService();

  @override
  Future<Hive?> getHiveById(String hiveId) async {
    try {
      return _sensorService.getHiveById(hiveId);
    } catch (e) {
      debugPrint('❌ Error getting hive by ID: $e');
      return null;
    }
  }

  @override
  Stream<CurrentState?> getCurrentState(String hiveId) {
    _sensorService.setCurrentHive(hiveId);
    return _sensorService.getCurrentState();
  }

  @override
  Future<List<SensorReading>> getSensorReadings(
      String hiveId, TimeFilter timeFilter) async {
    try {
      _sensorService.setCurrentHive(hiveId);
      _sensorService.setTimeFilter(timeFilter);

      // Pour obtenir les données de façon synchrone, on doit collecter le stream
      final readings = <SensorReading>[];
      await for (final batch in _sensorService.getSensorReadings()) {
        if (batch.isNotEmpty) {
          readings.addAll(batch);
          break; // On prend juste le premier lot
        }
      }

      return readings;
    } catch (e) {
      debugPrint('❌ Error getting sensor readings: $e');
      return [];
    }
  }

  @override
  Future<List<ThresholdEvent>> getThresholdEvents(String hiveId) async {
    try {
      _sensorService.setCurrentHive(hiveId);

      // Même approche que pour les lectures, on collecte le stream
      final events = <ThresholdEvent>[];
      await for (final batch in _sensorService.getThresholdEvents()) {
        if (batch.isNotEmpty) {
          events.addAll(batch);
          break; // On prend juste le premier lot
        }
      }

      return events;
    } catch (e) {
      debugPrint('❌ Error getting threshold events: $e');
      return [];
    }
  }

  @override
  Future<void> updateTemperatureThresholds(
      String hiveId, double lowThreshold, double highThreshold) async {
    try {
      _sensorService.setCurrentHive(hiveId);
      await _sensorService.updateThresholds(lowThreshold, highThreshold);
    } catch (e) {
      debugPrint('❌ Error updating temperature thresholds: $e');
      rethrow;
    }
  }

  @override
  Stream<List<SensorReading>> getSensorReadingsStream(String hiveId) {
    _sensorService.setCurrentHive(hiveId);
    return _sensorService.getSensorReadings();
  }

  @override
  Stream<List<ThresholdEvent>> getThresholdEventsStream(String hiveId) {
    _sensorService.setCurrentHive(hiveId);
    return _sensorService.getThresholdEvents();
  }
}
