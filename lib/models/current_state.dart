import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sensor_reading.dart';

/// Représente l'état actuel d'une ruche
class CurrentState extends Equatable {
  final double temperature;
  final double humidity;
  final double weight;
  final double soundLevel;
  final DateTime lastUpdated;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer un nouvel état
  const CurrentState({
    required this.temperature,
    required this.humidity,
    required this.weight,
    required this.soundLevel,
    required this.lastUpdated,
    this.metadata,
  });

  /// Constructeur à partir des données Firestore
  factory CurrentState.fromFirestore(Map<String, dynamic> data) {
    return CurrentState(
      temperature: (data['temperature'] as num).toDouble(),
      humidity: (data['humidity'] as num).toDouble(),
      weight: (data['weight'] as num).toDouble(),
      soundLevel: (data['sound_level'] as num).toDouble(),
      lastUpdated: (data['last_updated'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'weight': weight,
      'sound_level': soundLevel,
      'last_updated': lastUpdated,
      'metadata': metadata,
    };
  }

  /// Créer un état à partir d'une liste de lectures de capteurs
  factory CurrentState.fromReadings(List<SensorReading> readings) {
    final Map<String, SensorReading> latestReadings = {};

    // Trouver la lecture la plus récente pour chaque type de capteur
    for (final reading in readings) {
      if (!latestReadings.containsKey(reading.type) ||
          reading.timestamp.isAfter(latestReadings[reading.type]!.timestamp)) {
        latestReadings[reading.type] = reading;
      }
    }

    return CurrentState(
      temperature: latestReadings['temperature']?.value ?? 0.0,
      humidity: latestReadings['humidity']?.value ?? 0.0,
      weight: latestReadings['weight']?.value ?? 0.0,
      soundLevel: latestReadings['sound']?.value ?? 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        temperature,
        humidity,
        weight,
        soundLevel,
        lastUpdated,
        metadata,
      ];

  @override
  String toString() {
    return 'CurrentState(temp: $temperature°C, humidity: $humidity%, weight: $weight kg, sound: $soundLevel dB)';
  }
}
