import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return SensorReading(
      id: id,
      sensorId: data['sensor_id'] as String,
      type: data['type'] as String,
      value: (data['value'] as num).toDouble(),
      unit: data['unit'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour la base de données en temps réel
  Map<String, dynamic> toRealtimeDBMap() {
    return {
      'sensor_id': sensorId,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  /// Constructeur à partir des données Firestore
  factory SensorReading.fromFirestore(Map<String, dynamic> data, String id) {
    return SensorReading(
      id: id,
      sensorId: data['sensor_id'] as String,
      type: data['type'] as String,
      value: (data['value'] as num).toDouble(),
      unit: data['unit'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'sensor_id': sensorId,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp,
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
