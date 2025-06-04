import '../../models/hive.dart';
import '../../models/apiary.dart';
import '../../models/current_state.dart';
import '../../models/sensor_reading.dart';
import '../../models/threshold_event.dart';
import '../../models/time_filter.dart';

/// Interface abstraite pour l'accès aux données des capteurs
abstract class ISensorRepository {
  /// Récupère tous les ruchers
  Future<List<Apiary>> getApiaries();

  /// Récupère les ruches d'un rucher spécifique
  Future<List<Hive>> getHivesForApiary(String apiaryId);

  /// Récupère une ruche par son ID
  Future<Hive?> getHiveById(String hiveId);

  /// Récupère l'état actuel d'une ruche
  Stream<CurrentState?> getCurrentState(String hiveId);

  /// Récupère les lectures de capteurs d'une ruche
  Stream<List<SensorReading>> getSensorReadings(
      String hiveId, TimeFilter timeFilter);

  /// Récupère les événements de dépassement de seuil d'une ruche
  Stream<List<ThresholdEvent>> getThresholdEvents(String hiveId);

  /// Met à jour les seuils de température d'une ruche
  Future<void> updateThresholds(
      String hiveId, double lowThreshold, double highThreshold);

  /// Rafraîchit toutes les données
  Future<void> refreshAllData();

  /// Vérifie l'état de la connexion
  Future<bool> checkConnection();
}
