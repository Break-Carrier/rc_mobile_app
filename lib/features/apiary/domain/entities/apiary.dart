import 'package:equatable/equatable.dart';

/// Entité Rucher suivant les principes Clean Architecture
class Apiary extends Equatable {
  final String id;
  final String name;
  final String location;
  final String description;
  final String ownerId; // ID du propriétaire (Firebase Auth UID)
  final double? latitude;
  final double? longitude;
  final int hiveCount; // Nombre de ruches (dénormalisation)
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Apiary({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.ownerId,
    this.latitude,
    this.longitude,
    this.hiveCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crée une copie avec des modifications
  Apiary copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? ownerId,
    double? latitude,
    double? longitude,
    int? hiveCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Apiary(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hiveCount: hiveCount ?? this.hiveCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Retourne true si le rucher a des coordonnées GPS
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Retourne l'adresse complète
  String get fullLocation {
    if (hasCoordinates) {
      return '$location (${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)})';
    }
    return location;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        description,
        ownerId,
        latitude,
        longitude,
        hiveCount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Apiary{id: $id, name: $name, location: $location, hiveCount: $hiveCount}';
  }
}
