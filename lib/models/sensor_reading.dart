import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente une lecture de capteur
class SensorReading extends Equatable {
  final String sensorId;
  final String type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer une nouvelle lecture de capteur
  const SensorReading({
    required this.sensorId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
  });

  /// Constructeur à partir des données Firestore
  factory SensorReading.fromFirestore(Map<String, dynamic> data) {
    return SensorReading(
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
  List<Object?> get props => [sensorId, type, value, unit, timestamp, metadata];

  @override
  String toString() {
    return 'SensorReading(sensorId: $sensorId, type: $type, value: $value $unit)';
  }
}
