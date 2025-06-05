import '../../../sensor/domain/entities/hive.dart';
import '../../../sensor/domain/entities/current_state.dart';
import '../../../sensor/domain/entities/sensor_reading.dart';
import '../../../sensor/domain/entities/threshold_event.dart';
import '../../../sensor/domain/entities/time_filter.dart';

/// Interface définissant les méthodes d'accès aux données des ruches
abstract class IHiveRepository {
  /// Récupère une ruche par son ID
  Future<Hive?> getHiveById(String hiveId);

  /// Récupère l'état actuel d'une ruche
  Stream<CurrentState?> getCurrentState(String hiveId);

  /// Récupère les lectures de capteurs pour une ruche
  Future<List<SensorReading>> getSensorReadings(
      String hiveId, TimeFilter timeFilter);

  /// Récupère les événements de seuil pour une ruche
  Future<List<ThresholdEvent>> getThresholdEvents(String hiveId);

  /// Met à jour les seuils de température d'une ruche
  Future<void> updateTemperatureThresholds(
      String hiveId, double lowThreshold, double highThreshold);

  /// Écoute les lectures de capteurs en temps réel
  Stream<List<SensorReading>> getSensorReadingsStream(String hiveId);

  /// Écoute les événements de seuil en temps réel
  Stream<List<ThresholdEvent>> getThresholdEventsStream(String hiveId);
}
