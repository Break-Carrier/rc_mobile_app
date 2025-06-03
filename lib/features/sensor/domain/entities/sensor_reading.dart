import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props =>
      [id, sensorId, type, value, unit, timestamp, metadata];

  @override
  String toString() {
    return 'SensorReading(id: $id, type: $type, value: $value $unit, timestamp: $timestamp)';
  }
}
