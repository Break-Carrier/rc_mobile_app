import '../../domain/entities/hive.dart';
import '../../../sensor/domain/entities/hive_sensor_data.dart';

/// Modèle de données pour Firebase - Ruche
class HiveModel extends Hive {
  const HiveModel({
    required super.id,
    required super.name,
    required super.apiaryId,
    required super.ownerId,
    super.description,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
    super.lastInspection,
    super.sensorData,
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
      isActive: hive.isActive,
      createdAt: hive.createdAt,
      updatedAt: hive.updatedAt,
      lastInspection: hive.lastInspection,
      sensorData: hive.sensorData,
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
      sensorData: map['sensor'] != null
          ? HiveSensorData.fromFirebase(map['sensor'] as Map<String, dynamic>)
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
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastInspection': lastInspection?.millisecondsSinceEpoch,
      'sensor': sensorData?.toFirebase(),
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
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastInspection: lastInspection,
      sensorData: sensorData,
      metadata: metadata,
    );
  }

  /// Crée une copie avec mise à jour de la date
  HiveModel copyWithUpdate({
    String? name,
    String? description,
    bool? isActive,
    DateTime? lastInspection,
    HiveSensorData? sensorData,
    Map<String, dynamic>? metadata,
  }) {
    return HiveModel(
      id: id,
      name: name ?? this.name,
      apiaryId: apiaryId,
      ownerId: ownerId,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastInspection: lastInspection ?? this.lastInspection,
      sensorData: sensorData ?? this.sensorData,
      metadata: metadata ?? this.metadata,
    );
  }
}
