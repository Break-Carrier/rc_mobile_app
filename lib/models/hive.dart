import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sensor_reading.dart';
import 'current_state.dart';

/// Représente une ruche
class Hive extends Equatable {
  final String id;
  final String apiaryId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CurrentState? currentState;
  final List<SensorReading> recentReadings;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer une nouvelle ruche
  const Hive({
    required this.id,
    required this.apiaryId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.currentState,
    required this.recentReadings,
    this.metadata,
  });

  /// Constructeur à partir des données Firestore
  factory Hive.fromFirestore(Map<String, dynamic> data, String id) {
    return Hive(
      id: id,
      apiaryId: data['apiary_id'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      currentState: data['current_state'] != null
          ? CurrentState.fromFirestore(data['current_state'])
          : null,
      recentReadings: (data['recent_readings'] as List<dynamic>?)
              ?.map((reading) => SensorReading.fromFirestore(reading))
              .toList() ??
          [],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'apiary_id': apiaryId,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'current_state': currentState?.toMap(),
      'recent_readings':
          recentReadings.map((reading) => reading.toMap()).toList(),
      'metadata': metadata,
    };
  }

  /// Créer une copie avec des modifications
  Hive copyWith({
    String? name,
    String? description,
    CurrentState? currentState,
    List<SensorReading>? recentReadings,
    Map<String, dynamic>? metadata,
  }) {
    return Hive(
      id: id,
      apiaryId: apiaryId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      currentState: currentState ?? this.currentState,
      recentReadings: recentReadings ?? this.recentReadings,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        apiaryId,
        name,
        description,
        createdAt,
        updatedAt,
        currentState,
        recentReadings,
        metadata,
      ];

  @override
  String toString() {
    return 'Hive(id: $id, name: $name, apiaryId: $apiaryId)';
  }
}
