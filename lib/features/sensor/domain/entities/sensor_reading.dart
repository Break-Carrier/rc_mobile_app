import 'package:equatable/equatable.dart';

/// Représente une lecture de capteur
class SensorReading extends Equatable {
  final String id;
  final String hiveId;
  final double? temperature;
  final double? humidity;
  final double? weight;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer une nouvelle lecture
  const SensorReading({
    required this.id,
    required this.hiveId,
    this.temperature,
    this.humidity,
    this.weight,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        hiveId,
        temperature,
        humidity,
        weight,
        timestamp,
        metadata,
      ];

  @override
  String toString() {
    return 'SensorReading(id: $id, hiveId: $hiveId, temperature: $temperature, humidity: $humidity, weight: $weight, timestamp: $timestamp)';
  }
}
