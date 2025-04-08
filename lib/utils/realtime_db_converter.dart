import 'dart:convert';
import '../models/sensor_reading.dart';
import '../models/current_state.dart';

/// Utilitaires pour convertir les données de Realtime Database
class RealtimeDBConverter {
  /// Convertit les données JSON en CurrentState
  static CurrentState currentStateFromJson(Map<String, dynamic> json) {
    return CurrentState(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      weight: 0.0, // Non présent dans les données actuelles
      soundLevel: 0.0, // Non présent dans les données actuelles
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(json['lastUpdate'] as int),
      metadata: {
        'batteryLevel': json['batteryLevel'],
        'isThresholdExceeded': json['isThresholdExceeded'],
      },
    );
  }

  /// Convertit les données JSON en liste de SensorReading
  static List<SensorReading> sensorReadingsFromJson(Map<String, dynamic> json) {
    final readings = <SensorReading>[];

    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        // Lecture de température
        readings.add(SensorReading(
          sensorId: key,
          type: 'temperature',
          value: (value['temperature'] as num).toDouble(),
          unit: '°C',
          timestamp:
              DateTime.fromMillisecondsSinceEpoch(value['timestamp'] as int),
        ));

        // Lecture d'humidité
        readings.add(SensorReading(
          sensorId: key,
          type: 'humidity',
          value: (value['humidity'] as num).toDouble(),
          unit: '%',
          timestamp:
              DateTime.fromMillisecondsSinceEpoch(value['timestamp'] as int),
        ));
      }
    });

    return readings;
  }

  /// Convertit les données JSON des événements de seuil
  static List<Map<String, dynamic>> thresholdEventsFromJson(
      Map<String, dynamic> json) {
    final events = <Map<String, dynamic>>[];

    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        events.add({
          'id': key,
          'event': value['event'],
          'temperature': (value['temperature'] as num).toDouble(),
          'humidity': (value['humidity'] as num).toDouble(),
          'threshold': (value['threshold'] as num).toDouble(),
          'timestamp':
              DateTime.fromMillisecondsSinceEpoch(value['timestamp'] as int),
        });
      }
    });

    return events;
  }

  /// Parse une chaîne JSON en Map<String, dynamic>
  static Map<String, dynamic> parseJsonString(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid JSON string: $e');
    }
  }

  /// Convertit un Map<String, dynamic> en chaîne JSON
  static String toJsonString(Map<String, dynamic> data) {
    return json.encode(data);
  }
}
