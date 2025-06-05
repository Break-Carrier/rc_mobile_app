import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/sensor/domain/entities/sensor_reading.dart';
import '../../features/sensor/domain/entities/current_state.dart';

/// Convertisseur pour les données Firebase Realtime Database
class RealtimeDBConverter {
  /// Convertit les données Firebase en CurrentState
  static CurrentState? fromRealtimeDB(
      Map<String, dynamic>? data, String hiveId) {
    if (data == null) return null;

    return CurrentState(
      hiveId: hiveId,
      temperature: (data['temperature'] as num?)?.toDouble(),
      humidity: (data['humidity'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      isOnline: data['is_online'] == true,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertit une liste de données Firebase en SensorReadings
  static List<SensorReading> sensorReadingsFromRealtimeDB(
      Map<String, dynamic>? data, String hiveId) {
    if (data == null) return [];

    final readings = <SensorReading>[];
    data.forEach((key, value) {
      final readingData = Map<String, dynamic>.from(value as Map);
      readings.add(SensorReading(
        id: key,
        hiveId: hiveId,
        temperature: (readingData['temperature'] as num?)?.toDouble(),
        humidity: (readingData['humidity'] as num?)?.toDouble(),
        weight: (readingData['weight'] as num?)?.toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          readingData['timestamp'] as int,
        ),
        metadata: readingData['metadata'] as Map<String, dynamic>?,
      ));
    });

    return readings;
  }

  /// Convertit une lecture de capteur pour l'envoi vers Firebase
  static Map<String, dynamic> sensorReadingToRealtimeDB(SensorReading reading) {
    return {
      'hive_id': reading.hiveId,
      'temperature': reading.temperature,
      'humidity': reading.humidity,
      'weight': reading.weight,
      'timestamp': reading.timestamp.millisecondsSinceEpoch,
      'metadata': reading.metadata,
    };
  }

  /// Convertit un état actuel pour l'envoi vers Firebase
  static Map<String, dynamic> currentStateToRealtimeDB(CurrentState state) {
    return {
      'hive_id': state.hiveId,
      'temperature': state.temperature,
      'humidity': state.humidity,
      'weight': state.weight,
      'is_online': state.isOnline,
      'timestamp': state.timestamp.millisecondsSinceEpoch,
      'metadata': state.metadata,
    };
  }
}
