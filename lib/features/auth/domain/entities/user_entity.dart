import 'package:equatable/equatable.dart';

/// Entité utilisateur représentant un utilisateur authentifié
///
/// Cette entité provient de Firebase Authentication et contient
/// les informations de base d'authentification.
///
/// Pour les données métier étendues (ruchers, préférences),
/// utiliser UserProfile dans Realtime Database avec user.id comme clé.
class UserEntity extends Equatable {
  /// Identifiant unique de l'utilisateur (Firebase UID)
  final String id;

  /// Adresse email de l'utilisateur
  final String email;

  /// Nom d'affichage (optionnel)
  final String? displayName;

  /// Date de création du compte
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
  });

  /// Copie l'entité avec de nouvelles valeurs
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

  @override
  List<Object?> get props => [id, email, displayName, createdAt];
}
