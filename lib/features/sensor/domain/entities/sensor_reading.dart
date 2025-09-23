import 'package:equatable/equatable.dart';

/// Représente une lecture de capteur simplifiée
/// Utilisée pour l'historique des données de capteurs
class SensorReading extends Equatable {
  final String id;
  final String hiveId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer une nouvelle lecture
  const SensorReading({
    required this.id,
    required this.hiveId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    this.metadata,
  });

  /// Créer une instance depuis les données Firebase
  factory SensorReading.fromFirebase(
      Map<String, dynamic> data, String id, String hiveId) {
    return SensorReading(
      id: id,
      hiveId: hiveId,
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
      timestamp:
          DateTime.now(), // Firebase ne stocke pas le timestamp pour l'instant
      metadata: data,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hiveId,
        temperature,
        humidity,
        timestamp,
        metadata,
      ];

  @override
  String toString() {
    return 'SensorReading(id: $id, hiveId: $hiveId, temperature: ${temperature}°C, humidity: ${humidity}%, timestamp: $timestamp)';
  }
}
