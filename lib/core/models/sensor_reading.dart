import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Représente une lecture de capteur
class SensorReading extends Equatable {
  final String id;
  final String sensorId;
  final String type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer une nouvelle lecture
  const SensorReading({
    required this.id,
    required this.sensorId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
  });

  /// Créer une instance à partir des données de la base de données en temps réel
  factory SensorReading.fromRealtimeDB(Map<String, dynamic> data, String id) {
    try {
      // Pour la nouvelle structure, on reçoit directement les champs temperature et humidity
      // Déterminer le type de capteur (si pas explicite)
      String sensorType;
      if (data.containsKey('temperature')) {
        sensorType = 'temperature';
      } else if (data.containsKey('humidity')) {
        sensorType = 'humidity';
      } else if (data.containsKey('type')) {
        sensorType = data['type'] as String? ?? 'unknown';
      } else {
        sensorType = 'unknown';
      }

      // Déterminer la valeur selon le type détecté
      double value;
      if (sensorType == 'temperature' && data.containsKey('temperature')) {
        value = (data['temperature'] as num).toDouble();
      } else if (sensorType == 'humidity' && data.containsKey('humidity')) {
        value = (data['humidity'] as num).toDouble();
      } else if (data.containsKey('value')) {
        value = (data['value'] as num).toDouble();
      } else {
        throw FormatException('Aucune valeur trouvée pour ce capteur');
      }

      // Déterminer l'unité
      String unit;
      if (sensorType == 'temperature') {
        unit = data['unit_temperature'] as String? ?? '°C';
      } else if (sensorType == 'humidity') {
        unit = data['unit_humidity'] as String? ?? '%';
      } else if (data.containsKey('unit')) {
        unit = data['unit'] as String? ?? '';
      } else {
        unit = '';
      }

      // ID du capteur
      String sensorId = data['sensor_id'] as String? ??
          data['sensorId'] as String? ??
          'unknown';

      // Timestamp
      int timestampMs;
      if (data.containsKey('timestamp')) {
        timestampMs = data['timestamp'] as int;
      } else {
        timestampMs = DateTime.now().millisecondsSinceEpoch;
      }

      return SensorReading(
        id: id,
        sensorId: sensorId,
        type: sensorType,
        value: value,
        unit: unit,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
        metadata: data['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('❌ Error parsing sensor reading: $e - Data: $data');
      // Retourner une lecture factice plutôt que de lancer une exception
      return SensorReading(
        id: id,
        sensorId: 'error',
        type: 'error',
        value: 0.0,
        unit: '',
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Convertir en Map pour la base de données en temps réel
  Map<String, dynamic> toRealtimeDBMap() {
    final result = <String, dynamic>{
      'sensor_id': sensorId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };

    // Ajouter le bon champ selon le type
    if (type == 'temperature') {
      result['temperature'] = value;
      result['unit_temperature'] = unit;
    } else if (type == 'humidity') {
      result['humidity'] = value;
      result['unit_humidity'] = unit;
    } else {
      result['type'] = type;
      result['value'] = value;
      result['unit'] = unit;
    }

    if (metadata != null) {
      result['metadata'] = metadata;
    }

    return result;
  }

  /// Constructeur à partir des données Firestore
  factory SensorReading.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      return SensorReading(
        id: id,
        sensorId: data['sensor_id'] as String? ??
            data['sensorId'] as String? ??
            'unknown',
        type: data['type'] as String? ?? 'unknown',
        value: (data['value'] as num).toDouble(),
        unit: data['unit'] as String? ?? '',
        timestamp: data['timestamp'] is Timestamp
            ? (data['timestamp'] as Timestamp).toDate()
            : DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
        metadata: data['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('❌ Error parsing Firestore sensor reading: $e');
      // Retourner une lecture factice plutôt que de lancer une exception
      return SensorReading(
        id: id,
        sensorId: 'error',
        type: 'error',
        value: 0.0,
        unit: '',
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'sensor_id': sensorId,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props =>
      [id, sensorId, type, value, unit, timestamp, metadata];

  @override
  String toString() {
    return 'SensorReading(id: $id, type: $type, value: $value $unit, timestamp: $timestamp)';
  }
}
