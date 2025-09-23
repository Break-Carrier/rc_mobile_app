import 'package:equatable/equatable.dart';
import '../../../sensor/domain/entities/hive_sensor_data.dart';

/// Entité Ruche suivant les principes Clean Architecture
class Hive extends Equatable {
  final String id;
  final String name;
  final String apiaryId; // ID du rucher parent
  final String ownerId; // ID du propriétaire (Firebase Auth UID)
  final String? description;
  final bool isActive; // Ruche active ou non
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastInspection; // Dernière inspection
  final HiveSensorData? sensorData; // Données des capteurs intégrées
  final Map<String, dynamic>? metadata; // Données supplémentaires

  const Hive({
    required this.id,
    required this.name,
    required this.apiaryId,
    required this.ownerId,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastInspection,
    this.sensorData,
    this.metadata,
  });

  /// Créer une instance depuis les données Firebase
  factory Hive.fromFirebase(Map<String, dynamic> data, String id) {
    final sensorData = data['sensor'] != null
        ? HiveSensorData.fromFirebase(data['sensor'] as Map<String, dynamic>)
        : null;

    return Hive(
      id: id,
      name: data['nom'] as String? ?? '',
      apiaryId: data['rucherId'] as String? ?? '',
      ownerId:
          data['ownerId'] as String? ?? '', // À adapter selon votre structure
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt:
          DateTime.now(), // Firebase ne stocke pas ces dates pour l'instant
      updatedAt: DateTime.now(),
      lastInspection: data['lastInspection'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastInspection'] as int)
          : null,
      sensorData: sensorData,
      metadata: data,
    );
  }

  /// Crée une copie avec des modifications
  Hive copyWith({
    String? id,
    String? name,
    String? apiaryId,
    String? ownerId,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastInspection,
    HiveSensorData? sensorData,
    Map<String, dynamic>? metadata,
  }) {
    return Hive(
      id: id ?? this.id,
      name: name ?? this.name,
      apiaryId: apiaryId ?? this.apiaryId,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastInspection: lastInspection ?? this.lastInspection,
      sensorData: sensorData ?? this.sensorData,
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
        isActive,
        createdAt,
        updatedAt,
        lastInspection,
        sensorData,
        metadata,
      ];

  @override
  String toString() {
    return 'Hive{id: $id, name: $name, apiaryId: $apiaryId, isActive: $isActive}';
  }
}
