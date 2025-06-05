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

  /// Crée un modèle depuis les données Firebase
  factory HiveModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return HiveModel(
      id: id,
      name: map['name']?.toString() ?? '',
      apiaryId: map['apiaryId']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      description: map['description']?.toString(),
      hiveType: map['hiveType']?.toString(),
      material: map['material']?.toString(),
      frameCount: map['frameCount']?.toInt(),
      isActive: map['isActive'] == true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'].toInt())
          : null,
      lastInspection: map['lastInspection'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastInspection'].toInt())
          : null,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  /// Convertit vers le format Firebase
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'apiaryId': apiaryId,
      'ownerId': ownerId,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };

    // Ajouter les champs optionnels
    if (description != null) map['description'] = description;
    if (hiveType != null) map['hiveType'] = hiveType;
    if (material != null) map['material'] = material;
    if (frameCount != null) map['frameCount'] = frameCount;
    if (updatedAt != null) map['updatedAt'] = updatedAt!.millisecondsSinceEpoch;
    if (lastInspection != null) {
      map['lastInspection'] = lastInspection!.millisecondsSinceEpoch;
    }
    if (metadata != null) map['metadata'] = metadata;

    return map;
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
