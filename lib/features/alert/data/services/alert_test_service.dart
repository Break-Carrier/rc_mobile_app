import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/threshold_event.dart';
import '../models/threshold_event_model.dart';

/// Service pour ajouter des données de test d'alertes
class AlertTestService {
  final FirebaseDatabase _database;
  final String _basePath;
  final Logger _logger;

  AlertTestService({
    required FirebaseDatabase database,
    required String basePath,
    Logger? logger,
  })  : _database = database,
        _basePath = basePath,
        _logger = logger ?? Logger();

  /// Ajoute des alertes de test dans Firebase
  Future<void> addTestAlerts() async {
    try {
      _logger.i('🧪 Ajout d\'alertes de test...');

      final testAlerts = [
        _createTestAlert(
          id: 'test_alert_1',
          hiveId: 'hive_001',
          apiaryId: 'apiary_001',
          temperature: 35.5,
          humidity: 45.0,
          eventType: ThresholdEventType.exceeded,
          thresholdHigh: 30.0,
          thresholdLow: 15.0,
          description: 'Température élevée détectée',
        ),
        _createTestAlert(
          id: 'test_alert_2',
          hiveId: 'hive_002',
          apiaryId: 'apiary_001',
          temperature: 12.0,
          humidity: 85.0,
          eventType: ThresholdEventType.exceeded,
          thresholdHigh: 30.0,
          thresholdLow: 15.0,
          description: 'Température basse et humidité élevée',
        ),
        _createTestAlert(
          id: 'test_alert_3',
          hiveId: 'hive_003',
          apiaryId: 'apiary_002',
          temperature: 25.0,
          humidity: 60.0,
          eventType: ThresholdEventType.normal,
          thresholdHigh: 30.0,
          thresholdLow: 15.0,
          description: 'Conditions normales rétablies',
        ),
      ];

      // Ajouter les alertes dans Firebase
      for (final alert in testAlerts) {
        final alertData = ThresholdEventModel.fromEntity(alert).toMap();
        await _database
            .ref('$_basePath/alerts/${alert.hiveId}/${alert.id}')
            .set(alertData);
      }

      _logger
          .i('✅ ${testAlerts.length} alertes de test ajoutées avec succès !');
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'ajout des alertes de test: $e');
      rethrow;
    }
  }

  /// Supprime toutes les alertes de test
  Future<void> clearTestAlerts() async {
    try {
      _logger.i('🧹 Suppression des alertes de test...');

      final testAlertIds = ['test_alert_1', 'test_alert_2', 'test_alert_3'];
      final testHiveIds = ['hive_001', 'hive_002', 'hive_003'];

      for (final hiveId in testHiveIds) {
        for (final alertId in testAlertIds) {
          await _database.ref('$_basePath/alerts/$hiveId/$alertId').remove();
        }
      }

      _logger.i('✅ Alertes de test supprimées avec succès !');
    } catch (e) {
      _logger.e('❌ Erreur lors de la suppression des alertes de test: $e');
      rethrow;
    }
  }

  /// Crée une alerte de test
  ThresholdEvent _createTestAlert({
    required String id,
    required String hiveId,
    required String apiaryId,
    required double temperature,
    required double humidity,
    required ThresholdEventType eventType,
    required double thresholdHigh,
    required double thresholdLow,
    required String description,
  }) {
    return ThresholdEvent(
      id: id,
      temperature: temperature,
      humidity: humidity,
      timestamp: DateTime.now(),
      eventType: eventType,
      thresholdHigh: thresholdHigh,
      thresholdLow: thresholdLow,
      hiveId: hiveId,
      apiaryId: apiaryId,
      isRead: false,
    );
  }
}
