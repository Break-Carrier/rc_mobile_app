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

  /// Constructeur à partir des données Firestore ou Firebase Realtime Database
  factory Hive.fromFirestore(Map<String, dynamic> data, String id) {
    // Gérer les champs de date manquants
    final now = DateTime.now();
    DateTime createdAt;
    DateTime updatedAt;

    try {
      // Essayer de traiter les timestamps s'ils existent
      if (data['created_at'] is Timestamp) {
        createdAt = (data['created_at'] as Timestamp).toDate();
      } else if (data['created_at'] is int) {
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int);
      } else {
        createdAt = now; // Valeur par défaut si le champ est manquant
      }

      if (data['updated_at'] is Timestamp) {
        updatedAt = (data['updated_at'] as Timestamp).toDate();
      } else if (data['updated_at'] is int) {
        updatedAt =
            DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int);
      } else {
        updatedAt = now; // Valeur par défaut si le champ est manquant
      }
    } catch (e) {
      // En cas d'erreur, utiliser la date actuelle
      createdAt = now;
      updatedAt = now;
    }

    // Traiter l'état actuel
    CurrentState? currentState;
    if (data['current_state'] != null && data['current_state'] is Map) {
      try {
        currentState = CurrentState.fromFirestore(
            data['current_state'] as Map<String, dynamic>);
      } catch (e) {
        // Ignorer les erreurs de parsing
      }
    }

    // Extraire les lectures récentes (pas attendues dans la nouvelle structure)
    final List<SensorReading> recentReadings = [];

    return Hive(
      id: id,
      apiaryId: data['apiary_id'] as String? ?? '',
      name: data['name'] as String? ?? 'Ruche $id',
      description: data['description'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      currentState: currentState,
      recentReadings: recentReadings,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'apiary_id': apiaryId,
      'name': name,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'current_state': currentState?.toMap(),
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
