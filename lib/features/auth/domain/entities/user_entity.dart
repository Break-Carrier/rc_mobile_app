import 'package:equatable/equatable.dart';

/// Entité utilisateur pour le domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        createdAt,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
