import 'package:equatable/equatable.dart';

/// Représente une ruche
class Hive extends Equatable {
  final String id;
  final String apiaryId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  /// Constructeur pour créer une nouvelle ruche
  const Hive({
    required this.id,
    required this.apiaryId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Créer une copie avec des modifications
  Hive copyWith({
    String? name,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return Hive(
      id: id,
      apiaryId: apiaryId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
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
        metadata,
      ];

  @override
  String toString() {
    return 'Hive(id: $id, name: $name, apiaryId: $apiaryId)';
  }
}
