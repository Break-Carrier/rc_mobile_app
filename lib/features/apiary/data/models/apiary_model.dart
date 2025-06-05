import '../../domain/entities/apiary.dart';

/// Modèle de données pour Firebase - Rucher
class ApiaryModel extends Apiary {
  const ApiaryModel({
    required super.id,
    required super.name,
    required super.location,
    required super.description,
    required super.ownerId,
    super.latitude,
    super.longitude,
    super.hiveCount,
    required super.createdAt,
    super.updatedAt,
  });

  /// Crée un modèle depuis une entité
  factory ApiaryModel.fromEntity(Apiary apiary) {
    return ApiaryModel(
      id: apiary.id,
      name: apiary.name,
      location: apiary.location,
      description: apiary.description,
      ownerId: apiary.ownerId,
      latitude: apiary.latitude,
      longitude: apiary.longitude,
      hiveCount: apiary.hiveCount,
      createdAt: apiary.createdAt,
      updatedAt: apiary.updatedAt,
    );
  }

  /// Crée un modèle depuis les données Firebase
  factory ApiaryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ApiaryModel(
      id: id,
      name: map['name']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      latitude: map['coordinates']?['latitude']?.toDouble(),
      longitude: map['coordinates']?['longitude']?.toDouble(),
      hiveCount: map['hiveCount']?.toInt() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'].toInt())
          : null,
    );
  }

  /// Convertit vers le format Firebase
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'location': location,
      'description': description,
      'ownerId': ownerId,
      'hiveCount': hiveCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };

    // Ajouter les coordonnées si disponibles
    if (hasCoordinates) {
      map['coordinates'] = {
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    // Ajouter la date de mise à jour si disponible
    if (updatedAt != null) {
      map['updatedAt'] = updatedAt!.millisecondsSinceEpoch;
    }

    return map;
  }

  /// Crée une copie avec mise à jour de la date
  ApiaryModel copyWithUpdate({
    String? name,
    String? location,
    String? description,
    double? latitude,
    double? longitude,
    int? hiveCount,
  }) {
    return ApiaryModel(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      ownerId: ownerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hiveCount: hiveCount ?? this.hiveCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
