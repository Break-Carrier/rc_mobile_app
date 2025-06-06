import '../../domain/entities/hive.dart';

/// Modèle de données pour Firebase - Ruche
class HiveModel extends Hive {
  const HiveModel({
    required super.id,
    required super.name,
    required super.apiaryId,
    required super.ownerId,
    super.description,
    super.hiveType,
    super.material,
    super.frameCount,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
    super.lastInspection,
    super.metadata,
  });

  /// Crée un modèle depuis une entité
  factory HiveModel.fromEntity(Hive hive) {
    return HiveModel(
      id: hive.id,
      name: hive.name,
      apiaryId: hive.apiaryId,
      ownerId: hive.ownerId,
      description: hive.description,
      hiveType: hive.hiveType,
      material: hive.material,
      frameCount: hive.frameCount,
      isActive: hive.isActive,
      createdAt: hive.createdAt,
      updatedAt: hive.updatedAt,
      lastInspection: hive.lastInspection,
      metadata: hive.metadata,
    );
  }

  /// Crée un modèle depuis une Map Firebase
  factory HiveModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return HiveModel(
      id: id,
      name: map['name'] as String? ?? '',
      apiaryId: map['apiaryId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      description: map['description'] as String?,
      hiveType: map['hiveType'] as String?,
      material: map['material'] as String?,
      frameCount: map['frameCount'] as int?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      lastInspection: map['lastInspection'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastInspection'] as int)
          : null,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertit en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'apiaryId': apiaryId,
      'ownerId': ownerId,
      'description': description,
      'hiveType': hiveType,
      'material': material,
      'frameCount': frameCount,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastInspection': lastInspection?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  /// Convertit en entité
  Hive toEntity() {
    return Hive(
      id: id,
      name: name,
      apiaryId: apiaryId,
      ownerId: ownerId,
      description: description,
      hiveType: hiveType,
      material: material,
      frameCount: frameCount,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastInspection: lastInspection,
      metadata: metadata,
    );
  }

  /// Crée une copie avec mise à jour de la date
  HiveModel copyWithUpdate({
    String? name,
    String? description,
    String? hiveType,
    String? material,
    int? frameCount,
    bool? isActive,
    DateTime? lastInspection,
    Map<String, dynamic>? metadata,
  }) {
    return HiveModel(
      id: id,
      name: name ?? this.name,
      apiaryId: apiaryId,
      ownerId: ownerId,
      description: description ?? this.description,
      hiveType: hiveType ?? this.hiveType,
      material: material ?? this.material,
      frameCount: frameCount ?? this.frameCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastInspection: lastInspection ?? this.lastInspection,
      metadata: metadata ?? this.metadata,
    );
  }
}
