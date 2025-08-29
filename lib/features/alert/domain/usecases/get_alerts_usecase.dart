import '../../domain/entities/threshold_event.dart';
import '../../domain/repositories/alert_repository_interface.dart';

/// Use case pour récupérer les alertes
class GetAlertsUseCase {
  final IAlertRepository _alertRepository;

  GetAlertsUseCase(this._alertRepository);

  /// Récupère les dernières alertes
  Future<List<ThresholdEvent>> call({int limit = 20}) async {
    return await _alertRepository.getLatestAlerts(limit: limit);
  }

  /// Récupère les alertes pour une ruche spécifique
  Future<List<ThresholdEvent>> forHive(String hiveId, {int limit = 20}) async {
    return await _alertRepository.getAlertsForHive(hiveId, limit: limit);
  }

  /// Récupère les alertes pour un rucher spécifique
  Future<List<ThresholdEvent>> forApiary(String apiaryId,
      {int limit = 20}) async {
    return await _alertRepository.getAlertsForApiary(apiaryId, limit: limit);
  }

  /// Récupère les alertes dans une plage de temps
  Future<List<ThresholdEvent>> byTimeRange(
      DateTime startTime, DateTime endTime) async {
    return await _alertRepository.getAlertsByTimeRange(startTime, endTime);
  }

  /// Récupère les alertes non lues
  Future<List<ThresholdEvent>> unread({int limit = 20}) async {
    final allAlerts = await _alertRepository.getLatestAlerts(limit: limit * 2);
    final unreadAlerts = allAlerts.where((alert) => !alert.isRead).toList();
    return unreadAlerts.take(limit).toList();
  }

  /// Récupère les alertes critiques (dépassement de seuil)
  Future<List<ThresholdEvent>> critical({int limit = 20}) async {
    final allAlerts = await _alertRepository.getLatestAlerts(limit: limit * 2);
    final criticalAlerts =
        allAlerts.where((alert) => alert.isExceeded).toList();
    return criticalAlerts.take(limit).toList();
  }

  /// Récupère les alertes pour une ruche avec filtres
  Future<List<ThresholdEvent>> forHiveWithFilters(
    String hiveId, {
    int limit = 20,
    bool? isRead,
    bool? isExceeded,
    DateTime? since,
  }) async {
    final allAlerts =
        await _alertRepository.getAlertsForHive(hiveId, limit: limit * 2);

    var filteredAlerts = allAlerts;

    // Filtrer par statut de lecture
    if (isRead != null) {
      filteredAlerts =
          filteredAlerts.where((alert) => alert.isRead == isRead).toList();
    }

    // Filtrer par type d'événement
    if (isExceeded != null) {
      filteredAlerts = filteredAlerts
          .where((alert) => alert.isExceeded == isExceeded)
          .toList();
    }

    // Filtrer par date
    if (since != null) {
      filteredAlerts = filteredAlerts
          .where((alert) => alert.timestamp.isAfter(since))
          .toList();
    }

    return filteredAlerts.take(limit).toList();
  }
}
