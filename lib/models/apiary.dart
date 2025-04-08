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

  /// Constructeur à partir des données Firestore
  factory Apiary.fromFirestore(Map<String, dynamic> data, String id) {
    return Apiary(
      id: id,
      name: data['name'] as String,
      location: data['location'] as String,
      description: data['description'] as String?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      hiveIds: List<String>.from(data['hive_ids'] ?? []),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
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
