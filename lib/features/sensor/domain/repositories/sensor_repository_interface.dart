import '../entities/sensor_reading.dart';

/// Interface pour le repository de capteurs
abstract class ISensorRepository {
  /// Récupère les dernières lectures pour un capteur
  ///
  /// [sensorId] L'ID du capteur
  /// [limit] Le nombre maximum de lectures à récupérer
  Future<List<SensorReading>> getLatestReadings(String sensorId,
      {int limit = 10});

  /// Récupère les lectures pour un capteur dans une plage de temps
  ///
  /// [sensorId] L'ID du capteur
  /// [startTime] Le début de la plage de temps
  /// [endTime] La fin de la plage de temps
  Future<List<SensorReading>> getReadingsByTimeRange(
      String sensorId, DateTime startTime, DateTime endTime);

  /// Récupère les dernières lectures pour une ruche
  ///
  /// [hiveId] L'ID de la ruche
  /// [limit] Le nombre maximum de lectures à récupérer
  Future<List<SensorReading>> getLatestReadingsForHive(String hiveId,
      {int limit = 10});

  /// Récupère les lectures pour une ruche dans une plage de temps
  ///
  /// [hiveId] L'ID de la ruche
  /// [startTime] Le début de la plage de temps
  /// [endTime] La fin de la plage de temps
  Future<List<SensorReading>> getReadingsForHiveByTimeRange(
      String hiveId, DateTime startTime, DateTime endTime);

  /// S'abonne aux mises à jour des lectures pour un capteur
  ///
  /// [sensorId] L'ID du capteur
  Stream<List<SensorReading>> streamReadings(String sensorId);

  /// S'abonne aux mises à jour des lectures pour une ruche
  ///
  /// [hiveId] L'ID de la ruche
  Stream<List<SensorReading>> streamReadingsForHive(String hiveId);
}
