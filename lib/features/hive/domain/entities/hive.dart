import 'package:equatable/equatable.dart';

/// Entité Ruche suivant les principes Clean Architecture
class Hive extends Equatable {
  final String id;
  final String name;
  final String apiaryId; // ID du rucher parent
  final String ownerId; // ID du propriétaire (Firebase Auth UID)
  final String? description;
  final String? hiveType; // Type de ruche (Dadant, Langstroth, etc.)
  final String? material; // Matériau (bois, plastique, etc.)
  final int? frameCount; // Nombre de cadres
  final bool isActive; // Ruche active ou non
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastInspection; // Dernière inspection
  final Map<String, dynamic>? metadata; // Données supplémentaires

  const Hive({
    required this.id,
    required this.name,
    required this.apiaryId,
    required this.ownerId,
    this.description,
    this.hiveType,
    this.material,
    this.frameCount,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastInspection,
    this.metadata,
  });

  /// Crée une copie avec des modifications
  Hive copyWith({
    String? id,
    String? name,
    String? apiaryId,
    String? ownerId,
    String? description,
    String? hiveType,
    String? material,
    int? frameCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastInspection,
    Map<String, dynamic>? metadata,
  }) {
    return Hive(
      id: id ?? this.id,
      name: name ?? this.name,
      apiaryId: apiaryId ?? this.apiaryId,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      hiveType: hiveType ?? this.hiveType,
      material: material ?? this.material,
      frameCount: frameCount ?? this.frameCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastInspection: lastInspection ?? this.lastInspection,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Retourne le statut de la ruche
  String get status {
    if (!isActive) return 'Inactive';
    if (lastInspection == null) return 'Non inspectée';

    final daysSinceInspection =
        DateTime.now().difference(lastInspection!).inDays;
    if (daysSinceInspection > 30) return 'Inspection requise';
    if (daysSinceInspection > 14) return 'À surveiller';
    return 'Bonne condition';
  }

  /// Retourne true si une inspection est requise
  bool get needsInspection {
    if (lastInspection == null) return true;
    return DateTime.now().difference(lastInspection!).inDays > 30;
  }

  /// Retourne la couleur associée au statut
  String get statusColor {
    if (!isActive) return 'grey';
    if (needsInspection) return 'red';

    final daysSinceInspection = lastInspection != null
        ? DateTime.now().difference(lastInspection!).inDays
        : 999;

    if (daysSinceInspection > 14) return 'orange';
    return 'green';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        apiaryId,
        ownerId,
        description,
        hiveType,
        material,
        frameCount,
        isActive,
        createdAt,
        updatedAt,
        lastInspection,
        metadata,
      ];

  @override
  String toString() {
    return 'Hive{id: $id, name: $name, apiaryId: $apiaryId, isActive: $isActive}';
  }
}
