import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sensor_reading.dart';

/// Représente l'état actuel des capteurs
class CurrentState extends Equatable {
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final double thresholdHigh;
  final double thresholdLow;
  final bool isOverThreshold;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer un nouvel état
  const CurrentState({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.thresholdHigh,
    required this.thresholdLow,
    required this.isOverThreshold,
    this.metadata,
  });

  /// Constructeur à partir des données Firestore
  factory CurrentState.fromFirestore(Map<String, dynamic> data) {
    return CurrentState(
      temperature: (data['temperature'] as num).toDouble(),
      humidity: (data['humidity'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      thresholdHigh: (data['threshold_high'] as num).toDouble(),
      thresholdLow: (data['threshold_low'] as num).toDouble(),
      isOverThreshold: data['is_over_threshold'] as bool,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp,
      'threshold_high': thresholdHigh,
      'threshold_low': thresholdLow,
      'is_over_threshold': isOverThreshold,
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
      timestamp: DateTime.now(),
      thresholdHigh: 28.0,
      thresholdLow: 15.0,
      isOverThreshold: false,
    );
  }

  /// Vérifie si la température est élevée (> seuil haut)
  bool get isHighTemperature => temperature > thresholdHigh;

  /// Vérifie si la température est basse (< seuil bas)
  bool get isLowTemperature => temperature < thresholdLow;

  @override
  List<Object?> get props => [
        temperature,
        humidity,
        timestamp,
        thresholdHigh,
        thresholdLow,
        isOverThreshold,
        metadata
      ];

  @override
  String toString() {
    return 'CurrentState(temperature: $temperature°C, humidity: $humidity%, timestamp: $timestamp)';
  }

  /// Créer une instance à partir des données de la base de données en temps réel
  factory CurrentState.fromRealtimeDB(Map<String, dynamic> data) {
    return CurrentState(
      temperature: (data['temperature'] as num).toDouble(),
      humidity: (data['humidity'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
      thresholdHigh: (data['threshold_high'] as num).toDouble(),
      thresholdLow: (data['threshold_low'] as num).toDouble(),
      isOverThreshold: data['is_over_threshold'] as bool,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour la base de données en temps réel
  Map<String, dynamic> toRealtimeDBMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'threshold_high': thresholdHigh,
      'threshold_low': thresholdLow,
      'is_over_threshold': isOverThreshold,
      'metadata': metadata,
    };
  }
}
