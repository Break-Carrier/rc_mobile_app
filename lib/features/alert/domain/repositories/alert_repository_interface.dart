import '../entities/threshold_event.dart';

/// Interface pour le repository d'alertes
abstract class IAlertRepository {
  /// Récupère les dernières alertes
  /// 
  /// [limit] Le nombre maximum d'alertes à récupérer
  Future<List<ThresholdEvent>> getLatestAlerts({int limit = 20});
  
  /// Récupère les alertes pour une ruche spécifique
  /// 
  /// [hiveId] L'ID de la ruche
  /// [limit] Le nombre maximum d'alertes à récupérer
  Future<List<ThresholdEvent>> getAlertsForHive(String hiveId, {int limit = 20});
  
  /// Récupère les alertes pour un rucher spécifique
  /// 
  /// [apiaryId] L'ID du rucher
  /// [limit] Le nombre maximum d'alertes à récupérer
  Future<List<ThresholdEvent>> getAlertsForApiary(String apiaryId, {int limit = 20});
  
  /// Récupère les alertes entre deux dates
  /// 
  /// [startTime] Date de début
  /// [endTime] Date de fin
  Future<List<ThresholdEvent>> getAlertsByTimeRange(DateTime startTime, DateTime endTime);
  
  /// Marque une alerte comme lue
  /// 
  /// [alertId] L'ID de l'alerte à marquer
  /// [isRead] Indique si l'alerte est lue ou non
  Future<bool> markAlertAsRead(String alertId, {bool isRead = true});
  
  /// Supprime une alerte
  /// 
  /// [alertId] L'ID de l'alerte à supprimer
  Future<bool> deleteAlert(String alertId);
  
  /// S'abonne aux nouvelles alertes
  Stream<List<ThresholdEvent>> streamAlerts({int limit = 20});
  
  /// S'abonne aux nouvelles alertes pour une ruche spécifique
  /// 
  /// [hiveId] L'ID de la ruche
  Stream<List<ThresholdEvent>> streamAlertsForHive(String hiveId, {int limit = 20});
  
  /// S'abonne aux nouvelles alertes pour un rucher spécifique
  /// 
  /// [apiaryId] L'ID du rucher
  Stream<List<ThresholdEvent>> streamAlertsForApiary(String apiaryId, {int limit = 20});
} 