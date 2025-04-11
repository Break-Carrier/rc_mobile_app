import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hive.dart';

/// Représente un rucher
class Apiary extends Equatable {
  final String id;
  final String name;
  final String location;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> hiveIds;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer un nouveau rucher
  const Apiary({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.hiveIds,
    this.metadata,
  });

  /// Constructeur à partir des données Firestore ou Firebase Realtime Database
  factory Apiary.fromFirestore(Map<String, dynamic> data, String id) {
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

    // Extraire les IDs des ruches
    List<String> hiveIds = [];
    if (data['hive_ids'] != null) {
      if (data['hive_ids'] is List) {
        hiveIds = List<String>.from(data['hive_ids']);
      } else if (data['hive_ids'] is Map) {
        // Si c'est un Map, prendre les clés
        hiveIds =
            (data['hive_ids'] as Map).keys.map((k) => k.toString()).toList();
      }
    }

    return Apiary(
      id: id,
      name: data['name'] as String,
      location: data['location'] as String,
      description: data['description'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      hiveIds: hiveIds,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'hive_ids': hiveIds,
      'metadata': metadata,
    };
  }

  /// Créer une copie avec des modifications
  Apiary copyWith({
    String? name,
    String? location,
    String? description,
    List<String>? hiveIds,
    Map<String, dynamic>? metadata,
  }) {
    return Apiary(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      hiveIds: hiveIds ?? this.hiveIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        description,
        createdAt,
        updatedAt,
        hiveIds,
        metadata,
      ];

  @override
  String toString() {
    return 'Apiary(id: $id, name: $name, location: $location, hives: ${hiveIds.length})';
  }
}
