import 'package:flutter/foundation.dart';
import '../../../../core/models/hive.dart';
import '../../../../core/models/current_state.dart';
import '../../../../core/models/sensor_reading.dart';
import '../../../../core/models/threshold_event.dart';
import '../../../../core/models/time_filter.dart';
import '../../../../core/factories/service_factory.dart';
import '../../domain/repositories/hive_repository_interface.dart';

/// Implémentation du repository pour les ruches qui utilise HiveServiceCoordinator
class HiveRepository implements IHiveRepository {
  final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  Future<Hive?> getHiveById(String hiveId) async {
    try {
      // Récupérer toutes les ruches et chercher celle avec l'ID correspondant
      final apiaries = await coordinator.getApiaries();
      for (final apiary in apiaries) {
        final hives = await coordinator.getHivesForApiary(apiary.id);
        for (final hive in hives) {
          if (hive.id == hiveId) {
            return hive;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting hive by ID: $e');
      return null;
    }
  }

  @override
  Stream<CurrentState?> getCurrentState(String hiveId) {
    coordinator.setActiveHive(hiveId);
    return coordinator.getCurrentStateStream();
  }

  @override
  Future<List<SensorReading>> getSensorReadings(
      String hiveId, TimeFilter timeFilter) async {
    try {
      coordinator.setActiveHive(hiveId);
      coordinator.setTimeFilter(timeFilter);

      // Pour obtenir les données de façon synchrone, on doit collecter le stream
      final readings = <SensorReading>[];
      await for (final batch in coordinator.getSensorReadingsStream()) {
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
      coordinator.setActiveHive(hiveId);

      // Même approche que pour les lectures, on collecte le stream
      final events = <ThresholdEvent>[];
      await for (final batch in coordinator.getThresholdEventsStream()) {
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
      coordinator.setActiveHive(hiveId);
      await coordinator.updateThresholds(lowThreshold, highThreshold);
    } catch (e) {
      debugPrint('❌ Error updating temperature thresholds: $e');
      rethrow;
    }
  }

  @override
  Stream<List<SensorReading>> getSensorReadingsStream(String hiveId) {
    coordinator.setActiveHive(hiveId);
    return coordinator.getSensorReadingsStream();
  }

  @override
  Stream<List<ThresholdEvent>> getThresholdEventsStream(String hiveId) {
    coordinator.setActiveHive(hiveId);
    return coordinator.getThresholdEventsStream();
  }
}
