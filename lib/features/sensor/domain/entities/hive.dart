import 'package:equatable/equatable.dart';
import 'hive_sensor_data.dart';

/// Représente une ruche
class Hive extends Equatable {
  final String id;
  final String apiaryId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HiveSensorData? sensorData;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer une nouvelle ruche
  const Hive({
    required this.id,
    required this.apiaryId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
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
      apiaryId: data['rucherId'] as String? ?? '',
      name: data['nom'] as String? ?? '',
      description: data['description'] as String?,
      createdAt:
          DateTime.now(), // Firebase ne stocke pas ces dates pour l'instant
      updatedAt: DateTime.now(),
      sensorData: sensorData,
      metadata: data,
    );
  }

  /// Créer une copie avec des modifications
  Hive copyWith({
    String? name,
    String? description,
    HiveSensorData? sensorData,
    Map<String, dynamic>? metadata,
  }) {
    return Hive(
      id: id,
      apiaryId: apiaryId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sensorData: sensorData ?? this.sensorData,
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
        sensorData,
        metadata,
      ];

  @override
  String toString() {
    return 'Hive(id: $id, name: $name, apiaryId: $apiaryId)';
  }
}
