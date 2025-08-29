import '../../domain/entities/threshold_event.dart';
import '../../domain/repositories/alert_repository_interface.dart';

/// Use case pour gérer les alertes
class ManageAlertUseCase {
  final IAlertRepository _alertRepository;

  ManageAlertUseCase(this._alertRepository);

  /// Marque une alerte comme lue
  Future<bool> markAsRead(String alertId) async {
    return await _alertRepository.markAlertAsRead(alertId, isRead: true);
  }

  /// Marque une alerte comme non lue
  Future<bool> markAsUnread(String alertId) async {
    return await _alertRepository.markAlertAsRead(alertId, isRead: false);
  }

  /// Supprime une alerte
  Future<bool> delete(String alertId) async {
    return await _alertRepository.deleteAlert(alertId);
  }

  /// Marque plusieurs alertes comme lues
  Future<List<bool>> markMultipleAsRead(List<String> alertIds) async {
    final results = <bool>[];
    for (final alertId in alertIds) {
      final result = await markAsRead(alertId);
      results.add(result);
    }
    return results;
  }

  /// Marque toutes les alertes d'une ruche comme lues
  Future<bool> markAllHiveAlertsAsRead(String hiveId) async {
    try {
      final alerts =
          await _alertRepository.getAlertsForHive(hiveId, limit: 100);
      final unreadAlerts = alerts.where((alert) => !alert.isRead).toList();

      for (final alert in unreadAlerts) {
        if (alert.id != null) {
          await _alertRepository.markAlertAsRead(alert.id!, isRead: true);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Marque toutes les alertes d'un rucher comme lues
  Future<bool> markAllApiaryAlertsAsRead(String apiaryId) async {
    try {
      final alerts =
          await _alertRepository.getAlertsForApiary(apiaryId, limit: 100);
      final unreadAlerts = alerts.where((alert) => !alert.isRead).toList();

      for (final alert in unreadAlerts) {
        if (alert.id != null) {
          await _alertRepository.markAlertAsRead(alert.id!, isRead: true);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Supprime les anciennes alertes (plus de X jours)
  Future<bool> deleteOldAlerts(int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final oldAlerts = await _alertRepository.getAlertsByTimeRange(
        DateTime(2020), // Date très ancienne pour récupérer toutes les alertes
        cutoffDate,
      );

      for (final alert in oldAlerts) {
        if (alert.id != null) {
          await _alertRepository.deleteAlert(alert.id!);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Supprime toutes les alertes lues d'une ruche
  Future<bool> deleteReadAlertsForHive(String hiveId) async {
    try {
      final alerts =
          await _alertRepository.getAlertsForHive(hiveId, limit: 100);
      final readAlerts = alerts.where((alert) => alert.isRead).toList();

      for (final alert in readAlerts) {
        if (alert.id != null) {
          await _alertRepository.deleteAlert(alert.id!);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Supprime toutes les alertes résolues (retour à la normale) d'une ruche
  Future<bool> deleteResolvedAlertsForHive(String hiveId) async {
    try {
      final alerts =
          await _alertRepository.getAlertsForHive(hiveId, limit: 100);
      final resolvedAlerts = alerts.where((alert) => alert.isNormal).toList();

      for (final alert in resolvedAlerts) {
        if (alert.id != null) {
          await _alertRepository.deleteAlert(alert.id!);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
