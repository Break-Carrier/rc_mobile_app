import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../services/firebase_service.dart';
import '../../../../utils/map_converter.dart';
import '../../domain/entities/threshold_event.dart';
import '../../domain/repositories/alert_repository_interface.dart';
import '../models/threshold_event_model.dart';

/// Implémentation du repository pour les alertes
class AlertRepository implements IAlertRepository {
  final FirebaseService _firebaseService;

  AlertRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  @override
  Future<List<ThresholdEvent>> getLatestAlerts({int limit = 20}) async {
    try {
      await _ensureInitialized();

      final path = 'threshold_events';
      final data = await _firebaseService.getLatestEntries(path, limit);

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<ThresholdEventModel> alerts = [];
      data.forEach((key, value) {
        try {
          final alert = ThresholdEventModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);
          alerts.add(alert);
        } catch (e) {
          debugPrint('⚠️ Error parsing alert: $e');
        }
      });

      // Trier par timestamp (plus récent en premier)
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return alerts;
    } catch (e) {
      debugPrint('❌ Error fetching alerts: $e');
      return [];
    }
  }

  @override
  Future<List<ThresholdEvent>> getAlertsForHive(String hiveId,
      {int limit = 20}) async {
    try {
      await _ensureInitialized();

      // Pour l'instant, récupérer toutes les alertes et filtrer
      // Dans une future version, implémenter une requête spécifique par ruche
      final path = 'threshold_events';
      final data = await _firebaseService.getLatestEntries(
          path, limit * 2); // Charger plus d'éléments pour le filtrage

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<ThresholdEventModel> allAlerts = [];
      data.forEach((key, value) {
        try {
          final alert = ThresholdEventModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);

          // Ajouter l'alerte si elle correspond à la ruche demandée
          if (alert.hiveId == hiveId) {
            allAlerts.add(alert);
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing alert: $e');
        }
      });

      // Trier par timestamp (plus récent en premier)
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Limiter le nombre d'alertes retournées
      return allAlerts.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Error fetching alerts for hive: $e');
      return [];
    }
  }

  @override
  Future<List<ThresholdEvent>> getAlertsForApiary(String apiaryId,
      {int limit = 20}) async {
    try {
      await _ensureInitialized();

      // Pour l'instant, récupérer toutes les alertes et filtrer
      final path = 'threshold_events';
      final data = await _firebaseService.getLatestEntries(path, limit * 2);

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<ThresholdEventModel> allAlerts = [];
      data.forEach((key, value) {
        try {
          final alert = ThresholdEventModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);

          // Ajouter l'alerte si elle correspond au rucher demandé
          if (alert.apiaryId == apiaryId) {
            allAlerts.add(alert);
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing alert: $e');
        }
      });

      // Trier par timestamp (plus récent en premier)
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Limiter le nombre d'alertes retournées
      return allAlerts.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Error fetching alerts for apiary: $e');
      return [];
    }
  }

  @override
  Future<List<ThresholdEvent>> getAlertsByTimeRange(
      DateTime startTime, DateTime endTime) async {
    try {
      await _ensureInitialized();

      // Pour l'instant, récupérer toutes les alertes et filtrer par plage de temps
      final path = 'threshold_events';

      // Calculer une limite appropriée basée sur la plage de temps
      final differenceInDays = endTime.difference(startTime).inDays;
      final estimatedLimit =
          differenceInDays * 10; // Estimer ~10 alertes par jour
      final limit = estimatedLimit < 50
          ? 50
          : estimatedLimit > 500
              ? 500
              : estimatedLimit;

      final data = await _firebaseService.getLatestEntries(path, limit);

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<ThresholdEventModel> allAlerts = [];
      data.forEach((key, value) {
        try {
          final alert = ThresholdEventModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);
          allAlerts.add(alert);
        } catch (e) {
          debugPrint('⚠️ Error parsing alert: $e');
        }
      });

      // Filtrer par plage de temps
      final filteredAlerts = allAlerts
          .where((alert) =>
              alert.timestamp.isAfter(startTime) &&
              alert.timestamp.isBefore(endTime))
          .toList();

      // Trier par timestamp (plus récent en premier)
      filteredAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return filteredAlerts;
    } catch (e) {
      debugPrint('❌ Error fetching alerts by time range: $e');
      return [];
    }
  }

  @override
  Future<bool> markAlertAsRead(String alertId, {bool isRead = true}) async {
    try {
      await _ensureInitialized();

      final path = 'threshold_events/$alertId';

      // Récupérer l'alerte actuelle
      final data = await _firebaseService.getData(path);

      if (data == null) {
        debugPrint('⚠️ Alert not found: $alertId');
        return false;
      }

      // Mettre à jour le champ is_read
      await _firebaseService.updateData(path, {'is_read': isRead});

      debugPrint('✅ Alert $alertId marked as ${isRead ? 'read' : 'unread'}');
      return true;
    } catch (e) {
      debugPrint('❌ Error marking alert as read: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAlert(String alertId) async {
    try {
      await _ensureInitialized();

      final path = 'threshold_events/$alertId';
      await _firebaseService.deleteData(path);

      debugPrint('✅ Alert deleted: $alertId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting alert: $e');
      return false;
    }
  }

  @override
  Stream<List<ThresholdEvent>> streamAlerts({int limit = 20}) {
    try {
      _ensureInitialized();

      final path = 'threshold_events';

      return _firebaseService.getLatestEntriesStream(path, limit).map((event) {
        if (!event.snapshot.exists) {
          return <ThresholdEventModel>[];
        }

        try {
          if (event.snapshot.value is Map) {
            final rawData = event.snapshot.value as Map<Object?, Object?>;
            final Map<String, dynamic> data =
                MapConverter.convertToStringDynamicMap(rawData);

            final List<ThresholdEventModel> alerts = [];
            data.forEach((key, value) {
              try {
                final alert = ThresholdEventModel.fromRealtimeDB(
                    value as Map<String, dynamic>, key);
                alerts.add(alert);
              } catch (e) {
                debugPrint('⚠️ Error parsing alert in stream: $e');
              }
            });

            // Trier par timestamp (plus récent en premier)
            alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            return alerts;
          } else {
            return <ThresholdEventModel>[];
          }
        } catch (e) {
          debugPrint('❌ Error processing alerts stream: $e');
          throw Exception('Erreur lors du traitement du flux d\'alertes: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ Error setting up alerts stream: $e');
      return Stream.value(<ThresholdEventModel>[]);
    }
  }

  @override
  Stream<List<ThresholdEvent>> streamAlertsForHive(String hiveId,
      {int limit = 20}) {
    try {
      _ensureInitialized();

      // Pour l'instant, nous allons récupérer toutes les alertes et filtrer
      return streamAlerts(limit: limit * 2).map((alerts) => alerts
          .where(
              (alert) => alert is ThresholdEventModel && alert.hiveId == hiveId)
          .take(limit)
          .toList());
    } catch (e) {
      debugPrint('❌ Error setting up hive alerts stream: $e');
      return Stream.value(<ThresholdEventModel>[]);
    }
  }

  @override
  Stream<List<ThresholdEvent>> streamAlertsForApiary(String apiaryId,
      {int limit = 20}) {
    try {
      _ensureInitialized();

      // Pour l'instant, nous allons récupérer toutes les alertes et filtrer
      return streamAlerts(limit: limit * 2).map((alerts) => alerts
          .where((alert) =>
              alert is ThresholdEventModel && alert.apiaryId == apiaryId)
          .take(limit)
          .toList());
    } catch (e) {
      debugPrint('❌ Error setting up apiary alerts stream: $e');
      return Stream.value(<ThresholdEventModel>[]);
    }
  }

  /// S'assure que le service Firebase est initialisé
  Future<void> _ensureInitialized() async {
    if (!_firebaseService.isConnected) {
      try {
        await _firebaseService.initialize();
      } catch (e) {
        debugPrint('❌ Failed to initialize Firebase service: $e');
        throw Exception('Erreur d\'initialisation du service Firebase: $e');
      }
    }
  }
}
