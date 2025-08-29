import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/threshold_event.dart';
import '../../domain/entities/alert_settings.dart';
import '../models/threshold_event_model.dart';
import '../models/alert_settings_model.dart';

/// Service de détection d'alertes en temps réel
class AlertDetectionService {
  final FirebaseDatabase _database;
  final String _basePath;
  final Logger _logger;

  // Streams pour les données des capteurs
  final Map<String, StreamSubscription<DatabaseEvent>> _sensorSubscriptions =
      {};
  final Map<String, AlertSettings> _alertSettings = {};

  // Contrôleur pour les événements d'alertes
  final StreamController<List<ThresholdEvent>> _alertsController =
      StreamController<List<ThresholdEvent>>.broadcast();

  AlertDetectionService({
    required FirebaseDatabase database,
    required String basePath,
    Logger? logger,
  })  : _database = database,
        _basePath = basePath,
        _logger = logger ?? Logger();

  /// Stream des alertes détectées
  Stream<List<ThresholdEvent>> get alertsStream => _alertsController.stream;

  /// Initialise la surveillance des alertes pour une ruche
  Future<void> startMonitoringHive(String hiveId, String apiaryId) async {
    try {
      _logger.i(
          '🚨 Démarrage de la surveillance des alertes pour la ruche: $hiveId');

      // Charger les paramètres d'alertes pour cette ruche
      await _loadAlertSettings(hiveId, apiaryId);

      // Démarrer la surveillance des capteurs
      await _startSensorMonitoring(hiveId);
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du démarrage de la surveillance pour la ruche $hiveId: $e');
    }
  }

  /// Arrête la surveillance des alertes pour une ruche
  Future<void> stopMonitoringHive(String hiveId) async {
    try {
      _logger
          .i('🛑 Arrêt de la surveillance des alertes pour la ruche: $hiveId');

      // Arrêter la subscription aux capteurs
      _sensorSubscriptions[hiveId]?.cancel();
      _sensorSubscriptions.remove(hiveId);

      // Supprimer les paramètres d'alertes
      _alertSettings.remove(hiveId);
    } catch (e) {
      _logger.e(
          '❌ Erreur lors de l\'arrêt de la surveillance pour la ruche $hiveId: $e');
    }
  }

  /// Charge les paramètres d'alertes pour une ruche
  Future<void> _loadAlertSettings(String hiveId, String apiaryId) async {
    try {
      // Essayer de charger les paramètres spécifiques à la ruche
      final hiveSettings = await _loadHiveAlertSettings(hiveId);
      if (hiveSettings != null) {
        _alertSettings[hiveId] = hiveSettings;
        _logger.d('✅ Paramètres d\'alertes chargés pour la ruche: $hiveId');
        return;
      }

      // Sinon, charger les paramètres du rucher
      final apiarySettings = await _loadApiaryAlertSettings(apiaryId);
      if (apiarySettings != null) {
        _alertSettings[hiveId] = apiarySettings;
        _logger.d(
            '✅ Paramètres d\'alertes du rucher chargés pour la ruche: $hiveId');
        return;
      }

      // Sinon, utiliser les paramètres par défaut
      final defaultSettings = AlertSettingsModel.defaultForHive(hiveId);
      _alertSettings[hiveId] = defaultSettings;
      _logger.d(
          '✅ Paramètres d\'alertes par défaut utilisés pour la ruche: $hiveId');
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du chargement des paramètres d\'alertes pour la ruche $hiveId: $e');

      // Utiliser les paramètres par défaut en cas d'erreur
      final defaultSettings = AlertSettingsModel.defaultForHive(hiveId);
      _alertSettings[hiveId] = defaultSettings;
    }
  }

  /// Charge les paramètres d'alertes spécifiques à une ruche
  Future<AlertSettings?> _loadHiveAlertSettings(String hiveId) async {
    try {
      final snapshot =
          await _database.ref('$_basePath/alert_settings/hives/$hiveId').once();

      if (!snapshot.snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      return AlertSettingsModel.fromRealtimeDB(data, hiveId);
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du chargement des paramètres d\'alertes de la ruche $hiveId: $e');
      return null;
    }
  }

  /// Charge les paramètres d'alertes d'un rucher
  Future<AlertSettings?> _loadApiaryAlertSettings(String apiaryId) async {
    try {
      final snapshot = await _database
          .ref('$_basePath/alert_settings/apiaries/$apiaryId')
          .once();

      if (!snapshot.snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      return AlertSettingsModel.fromRealtimeDB(data, apiaryId);
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du chargement des paramètres d\'alertes du rucher $apiaryId: $e');
      return null;
    }
  }

  /// Démarre la surveillance des capteurs pour une ruche
  Future<void> _startSensorMonitoring(String hiveId) async {
    try {
      // Arrêter la surveillance existante si elle existe
      _sensorSubscriptions[hiveId]?.cancel();

      // Démarrer la nouvelle surveillance
      _sensorSubscriptions[hiveId] = _database
          .ref('$_basePath/hives/$hiveId/sensor')
          .onValue
          .listen((event) {
        _processSensorData(hiveId, event);
      });

      _logger.d('✅ Surveillance des capteurs démarrée pour la ruche: $hiveId');
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du démarrage de la surveillance des capteurs pour la ruche $hiveId: $e');
    }
  }

  /// Traite les données des capteurs et détecte les alertes
  void _processSensorData(String hiveId, DatabaseEvent event) {
    try {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final temperature = (data['temperature'] as num?)?.toDouble();
      final humidity = (data['humidity'] as num?)?.toDouble();

      if (temperature == null && humidity == null) return;

      final settings = _alertSettings[hiveId];
      if (settings == null) {
        _logger.w('⚠️ Aucun paramètre d\'alerte trouvé pour la ruche: $hiveId');
        return;
      }

      final alerts = <ThresholdEvent>[];

      // Vérifier les alertes de température
      if (temperature != null) {
        final tempAlert = _checkTemperatureAlert(hiveId, temperature, settings);
        if (tempAlert != null) {
          alerts.add(tempAlert);
        }
      }

      // Vérifier les alertes d'humidité
      if (humidity != null) {
        final humidityAlert = _checkHumidityAlert(hiveId, humidity, settings);
        if (humidityAlert != null) {
          alerts.add(humidityAlert);
        }
      }

      // Émettre les alertes détectées
      if (alerts.isNotEmpty) {
        _emitAlerts(alerts);
        _saveAlertsToDatabase(alerts);
      }
    } catch (e) {
      _logger.e(
          '❌ Erreur lors du traitement des données des capteurs pour la ruche $hiveId: $e');
    }
  }

  /// Vérifie s'il y a une alerte de température
  ThresholdEvent? _checkTemperatureAlert(
      String hiveId, double temperature, AlertSettings settings) {
    if (!settings.isTemperatureAlert(temperature)) return null;

    final alertType = settings.getTemperatureAlertType(temperature);
    if (alertType == null) return null;

    final eventType = alertType.contains('high') || alertType.contains('low')
        ? ThresholdEventType.exceeded
        : ThresholdEventType.normal;

    return ThresholdEventModel(
      temperature: temperature,
      humidity: 0.0, // Sera mis à jour si disponible
      timestamp: DateTime.now(),
      eventType: eventType,
      thresholdHigh: settings.temperatureHighThreshold,
      thresholdLow: settings.temperatureLowThreshold,
      hiveId: hiveId,
      isRead: false,
    );
  }

  /// Vérifie s'il y a une alerte d'humidité
  ThresholdEvent? _checkHumidityAlert(
      String hiveId, double humidity, AlertSettings settings) {
    if (!settings.isHumidityAlert(humidity)) return null;

    final alertType = settings.getHumidityAlertType(humidity);
    if (alertType == null) return null;

    final eventType = alertType.contains('high') || alertType.contains('low')
        ? ThresholdEventType.exceeded
        : ThresholdEventType.normal;

    return ThresholdEventModel(
      temperature: 0.0, // Sera mis à jour si disponible
      humidity: humidity,
      timestamp: DateTime.now(),
      eventType: eventType,
      thresholdHigh: settings.humidityHighThreshold,
      thresholdLow: settings.humidityLowThreshold,
      hiveId: hiveId,
      isRead: false,
    );
  }

  /// Émet les alertes via le stream
  void _emitAlerts(List<ThresholdEvent> alerts) {
    try {
      _alertsController.add(alerts);
      _logger.i('🚨 ${alerts.length} alerte(s) détectée(s) et émise(s)');
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'émission des alertes: $e');
    }
  }

  /// Sauvegarde les alertes dans la base de données
  Future<void> _saveAlertsToDatabase(List<ThresholdEvent> alerts) async {
    try {
      for (final alert in alerts) {
        if (alert.hiveId == null) continue;

        final alertModel = ThresholdEventModel.fromEntity(alert);
        final alertData = alertModel.toMap();

        // Sauvegarder dans la base de données
        await _database
            .ref(
                '$_basePath/alerts/${alert.hiveId}/${DateTime.now().millisecondsSinceEpoch}')
            .set(alertData);

        _logger.d('💾 Alerte sauvegardée dans la base de données: ${alert.id}');
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de la sauvegarde des alertes: $e');
    }
  }

  /// Met à jour les paramètres d'alertes pour une ruche
  Future<void> updateAlertSettings(
      String hiveId, AlertSettings newSettings) async {
    try {
      _alertSettings[hiveId] = newSettings;

      // Sauvegarder dans la base de données
      final settingsModel = AlertSettingsModel.fromEntity(newSettings);
      final settingsData = settingsModel.toRealtimeDBMap();

      await _database
          .ref('$_basePath/alert_settings/hives/$hiveId')
          .set(settingsData);

      _logger.i('✅ Paramètres d\'alertes mis à jour pour la ruche: $hiveId');
    } catch (e) {
      _logger.e(
          '❌ Erreur lors de la mise à jour des paramètres d\'alertes pour la ruche $hiveId: $e');
    }
  }

  /// Récupère les paramètres d'alertes actuels pour une ruche
  AlertSettings? getAlertSettings(String hiveId) {
    return _alertSettings[hiveId];
  }

  /// Libère les ressources
  void dispose() {
    // Annuler toutes les subscriptions
    for (final subscription in _sensorSubscriptions.values) {
      subscription.cancel();
    }
    _sensorSubscriptions.clear();

    // Fermer le contrôleur de stream
    _alertsController.close();

    _logger.i('🧹 Service de détection d\'alertes nettoyé');
  }
}
