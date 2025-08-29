import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/entities/threshold_event.dart';
import '../../domain/entities/alert_settings.dart';
import '../../domain/repositories/alert_repository_interface.dart';
import '../models/threshold_event_model.dart';
import '../models/alert_settings_model.dart';
import '../services/alert_detection_service.dart';

/// Implémentation du repository pour les alertes avec Firebase
class AlertRepository implements IAlertRepository {
  final FirebaseDatabase _database;
  final String _basePath;
  final Logger _logger;
  final AlertDetectionService _detectionService;

  AlertRepository({
    FirebaseDatabase? database,
    String? basePath,
    Logger? logger,
  })  : _database = database ?? FirebaseDatabase.instance,
        _basePath = basePath ?? AppConfig.firebaseBasePath,
        _logger = logger ?? Logger(),
        _detectionService = AlertDetectionService(
          database: database ?? FirebaseDatabase.instance,
          basePath: basePath ?? AppConfig.firebaseBasePath,
          logger: logger,
        );

  @override
  Future<List<ThresholdEvent>> getLatestAlerts({int limit = 20}) async {
    try {
      _logger.d('📋 Récupération des dernières alertes (limite: $limit)');

      final snapshot = await _database
          .ref('$_basePath/alerts')
          .orderByKey()
          .limitToLast(limit)
          .once();

      if (!snapshot.snapshot.exists) {
        return [];
      }

      final alerts = <ThresholdEvent>[];
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      // Traiter les alertes par ruche
      for (final hiveEntry in data.entries) {
        final hiveId = hiveEntry.key;
        final hiveAlerts = Map<String, dynamic>.from(hiveEntry.value as Map);

        for (final alertEntry in hiveAlerts.entries) {
          final alertId = alertEntry.key;
          final alertData = Map<String, dynamic>.from(alertEntry.value as Map);

          final alert = ThresholdEventModel.fromRealtimeDB(alertData, alertId);
          alerts.add(alert);
        }
      }

      // Trier par timestamp décroissant et limiter
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts.take(limit).toList();
    } catch (e) {
      _logger.e('❌ Erreur lors de la récupération des dernières alertes: $e');
      return [];
    }
  }

  @override
  Future<List<ThresholdEvent>> getAlertsForHive(String hiveId,
      {int limit = 20}) async {
    try {
      _logger.d(
          '📋 Récupération des alertes pour la ruche: $hiveId (limite: $limit)');

      final snapshot = await _database
          .ref('$_basePath/alerts/$hiveId')
          .orderByKey()
          .limitToLast(limit)
          .once();

      if (!snapshot.snapshot.exists) {
        return [];
      }

      final alerts = <ThresholdEvent>[];
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      for (final entry in data.entries) {
        final alertId = entry.key;
        final alertData = Map<String, dynamic>.from(entry.value as Map);

        final alert = ThresholdEventModel.fromRealtimeDB(alertData, alertId);
        alerts.add(alert);
      }

      // Trier par timestamp décroissant
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    } catch (e) {
      _logger.e(
          '❌ Erreur lors de la récupération des alertes pour la ruche $hiveId: $e');
      return [];
    }
  }

  @override
  Future<List<ThresholdEvent>> getAlertsForApiary(String apiaryId,
      {int limit = 20}) async {
    try {
      _logger.d(
          '📋 Récupération des alertes pour le rucher: $apiaryId (limite: $limit)');

      // D'abord, récupérer toutes les ruches du rucher
      final apiarySnapshot =
          await _database.ref('$_basePath/apiary_hives/$apiaryId').once();

      if (!apiarySnapshot.snapshot.exists) {
        return [];
      }

      final hiveIds = <String>[];
      final apiaryHivesData =
          Map<String, dynamic>.from(apiarySnapshot.snapshot.value as Map);

      for (final entry in apiaryHivesData.entries) {
        if (entry.value == true) {
          hiveIds.add(entry.key);
        }
      }

      // Récupérer les alertes pour chaque ruche
      final allAlerts = <ThresholdEvent>[];
      for (final hiveId in hiveIds) {
        final hiveAlerts = await getAlertsForHive(hiveId, limit: limit);
        allAlerts.addAll(hiveAlerts);
      }

      // Trier par timestamp décroissant et limiter
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allAlerts.take(limit).toList();
    } catch (e) {
      _logger.e(
          '❌ Erreur lors de la récupération des alertes pour le rucher $apiaryId: $e');
      return [];
    }
  }

  @override
  Future<List<ThresholdEvent>> getAlertsByTimeRange(
      DateTime startTime, DateTime endTime) async {
    try {
      _logger.d(
          '📋 Récupération des alertes entre ${startTime.toIso8601String()} et ${endTime.toIso8601String()}');

      final startTimestamp = startTime.millisecondsSinceEpoch;
      final endTimestamp = endTime.millisecondsSinceEpoch;

      final snapshot = await _database
          .ref('$_basePath/alerts')
          .orderByKey()
          .startAt(startTimestamp.toString())
          .endAt(endTimestamp.toString())
          .once();

      if (!snapshot.snapshot.exists) {
        return [];
      }

      final alerts = <ThresholdEvent>[];
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      // Traiter les alertes par ruche
      for (final hiveEntry in data.entries) {
        final hiveId = hiveEntry.key;
        final hiveAlerts = Map<String, dynamic>.from(hiveEntry.value as Map);

        for (final alertEntry in hiveAlerts.entries) {
          final alertId = alertEntry.key;
          final alertData = Map<String, dynamic>.from(alertEntry.value as Map);

          final alert = ThresholdEventModel.fromRealtimeDB(alertData, alertId);
          alerts.add(alert);
        }
      }

      // Trier par timestamp décroissant
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    } catch (e) {
      _logger.e(
          '❌ Erreur lors de la récupération des alertes par plage de temps: $e');
      return [];
    }
  }

  @override
  Stream<List<ThresholdEvent>> streamAlerts({int limit = 20}) {
    try {
      _logger.d('📡 Démarrage du stream des alertes (limite: $limit)');

      return _database
          .ref('$_basePath/alerts')
          .orderByKey()
          .limitToLast(limit)
          .onValue
          .map((event) {
        if (!event.snapshot.exists) return <ThresholdEvent>[];

        final alerts = <ThresholdEvent>[];
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        // Traiter les alertes par ruche
        for (final hiveEntry in data.entries) {
          final hiveId = hiveEntry.key;
          final hiveAlerts = Map<String, dynamic>.from(hiveEntry.value as Map);

          for (final alertEntry in hiveAlerts.entries) {
            final alertId = alertEntry.key;
            final alertData =
                Map<String, dynamic>.from(alertEntry.value as Map);

            final alert =
                ThresholdEventModel.fromRealtimeDB(alertData, alertId);
            alerts.add(alert);
          }
        }

        // Trier par timestamp décroissant et limiter
        alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return alerts.take(limit).toList();
      });
    } catch (e) {
      _logger.e('❌ Erreur lors du démarrage du stream des alertes: $e');
      return Stream.value(<ThresholdEvent>[]);
    }
  }

  @override
  Stream<List<ThresholdEvent>> streamAlertsForHive(String hiveId,
      {int limit = 20}) {
    try {
      _logger.d(
          '📡 Démarrage du stream des alertes pour la ruche: $hiveId (limite: $limit)');

      return _database
          .ref('$_basePath/alerts/$hiveId')
          .orderByKey()
          .limitToLast(limit)
          .onValue
          .map((event) {
        if (!event.snapshot.exists) return <ThresholdEvent>[];

        final alerts = <ThresholdEvent>[];
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        for (final entry in data.entries) {
          final alertId = entry.key;
          final alertData = Map<String, dynamic>.from(entry.value as Map);

          final alert = ThresholdEventModel.fromRealtimeDB(alertData, alertId);
          alerts.add(alert);
        }

        // Trier par timestamp décroissant
        alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return alerts;
      });
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du démarrage du stream des alertes pour la ruche $hiveId: $e');
      return Stream.value(<ThresholdEvent>[]);
    }
  }

  @override
  Stream<List<ThresholdEvent>> streamAlertsForApiary(String apiaryId,
      {int limit = 20}) {
    try {
      _logger.d(
          '📡 Démarrage du stream des alertes pour le rucher: $apiaryId (limite: $limit)');

      // Utiliser le service de détection pour combiner les streams de toutes les ruches
      return _detectionService.alertsStream.map((alerts) {
        // Filtrer les alertes du rucher spécifique
        final apiaryAlerts = alerts.where((alert) {
          // Vérifier si l'alerte appartient à une ruche du rucher
          // Cette logique nécessite de connaître la relation ruche-rucher
          return true; // TODO: Implémenter la logique de filtrage
        }).toList();

        // Trier et limiter
        apiaryAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return apiaryAlerts.take(limit).toList();
      });
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du démarrage du stream des alertes pour le rucher $apiaryId: $e');
      return Stream.value(<ThresholdEvent>[]);
    }
  }

  @override
  Future<bool> markAlertAsRead(String alertId, {bool isRead = true}) async {
    try {
      _logger.d(
          '📝 Marquage de l\'alerte $alertId comme ${isRead ? "lue" : "non lue"}');

      // Trouver l'alerte dans la base de données
      final snapshot =
          await _database.ref('$_basePath/alerts').orderByKey().once();

      if (!snapshot.snapshot.exists) {
        return false;
      }

      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      String? hiveId;
      String? foundAlertId;

      // Chercher l'alerte dans toutes les ruches
      for (final hiveEntry in data.entries) {
        final hiveAlerts = Map<String, dynamic>.from(hiveEntry.value as Map);
        if (hiveAlerts.containsKey(alertId)) {
          hiveId = hiveEntry.key;
          foundAlertId = alertId;
          break;
        }
      }

      if (hiveId == null || foundAlertId == null) {
        _logger.w('⚠️ Alerte $alertId non trouvée');
        return false;
      }

      // Mettre à jour le statut de lecture
      await _database
          .ref('$_basePath/alerts/$hiveId/$foundAlertId/is_read')
          .set(isRead);

      _logger
          .i('✅ Alerte $alertId marquée comme ${isRead ? "lue" : "non lue"}');
      return true;
    } catch (e) {
      _logger.e('❌ Erreur lors du marquage de l\'alerte $alertId: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAlert(String alertId) async {
    try {
      _logger.d('🗑️ Suppression de l\'alerte: $alertId');

      // Trouver l'alerte dans la base de données
      final snapshot =
          await _database.ref('$_basePath/alerts').orderByKey().once();

      if (!snapshot.snapshot.exists) {
        return false;
      }

      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      String? hiveId;
      String? foundAlertId;

      // Chercher l'alerte dans toutes les ruches
      for (final hiveEntry in data.entries) {
        final hiveAlerts = Map<String, dynamic>.from(hiveEntry.value as Map);
        if (hiveAlerts.containsKey(alertId)) {
          hiveId = hiveEntry.key;
          foundAlertId = alertId;
          break;
        }
      }

      if (hiveId == null || foundAlertId == null) {
        _logger.w('⚠️ Alerte $alertId non trouvée');
        return false;
      }

      // Supprimer l'alerte
      await _database.ref('$_basePath/alerts/$hiveId/$foundAlertId').remove();

      _logger.i('✅ Alerte $alertId supprimée');
      return true;
    } catch (e) {
      _logger.e('❌ Erreur lors de la suppression de l\'alerte $alertId: $e');
      return false;
    }
  }

  /// Démarre la surveillance des alertes pour une ruche
  Future<void> startMonitoringHive(String hiveId, String apiaryId) async {
    await _detectionService.startMonitoringHive(hiveId, apiaryId);
  }

  /// Arrête la surveillance des alertes pour une ruche
  Future<void> stopMonitoringHive(String hiveId) async {
    await _detectionService.stopMonitoringHive(hiveId);
  }

  /// Met à jour les paramètres d'alertes pour une ruche
  Future<void> updateAlertSettings(
      String hiveId, AlertSettings settings) async {
    await _detectionService.updateAlertSettings(hiveId, settings);
  }

  /// Récupère les paramètres d'alertes pour une ruche
  AlertSettings? getAlertSettings(String hiveId) {
    return _detectionService.getAlertSettings(hiveId);
  }

  /// Libère les ressources
  void dispose() {
    _detectionService.dispose();
    _logger.i('🧹 Repository d\'alertes nettoyé');
  }
}
