import 'package:equatable/equatable.dart';

/// Énumération des rôles utilisateur disponibles dans l'application
enum UserRoleType {
  /// Administrateur avec droits complets
  admin('admin', 'Administrateur'),

  /// Apiculteur standard
  beekeeper('beekeeper', 'Apiculteur'),

  /// Apiculteur en attente de validation
  pendingBeekeeper('pending_beekeeper', 'Apiculteur en attente');

  const UserRoleType(this.value, this.displayName);

  /// Valeur stockée en base de données
  final String value;

  /// Nom d'affichage pour l'interface utilisateur
  final String displayName;

  /// Convertit une string en UserRoleType
  static UserRoleType fromString(String value) {
    return UserRoleType.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRoleType.beekeeper,
    );
  }
}

/// Entité représentant le rôle d'un utilisateur avec ses permissions
class UserRoleEntity extends Equatable {
  /// Type de rôle
  final UserRoleType roleType;

  /// Date d'attribution du rôle
  final DateTime assignedAt;

  /// ID de l'administrateur qui a attribué le rôle (optionnel)
  final String? assignedBy;

  /// Statut actif/inactif du rôle
  final bool isActive;

  /// Permissions spécifiques (pour extensions futures)
  final List<String> permissions;

  const UserRoleEntity({
    required this.roleType,
    required this.assignedAt,
    this.assignedBy,
    this.isActive = true,
    this.permissions = const [],
  });

  /// Vérifie si l'utilisateur est administrateur
  bool get isAdmin => roleType == UserRoleType.admin && isActive;

  /// Vérifie si l'utilisateur est un apiculteur validé
  bool get isValidatedBeekeeper =>
      roleType == UserRoleType.beekeeper && isActive;

  /// Vérifie si l'utilisateur est en attente de validation
  bool get isPendingValidation =>
      roleType == UserRoleType.pendingBeekeeper && isActive;

  /// Vérifie si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    if (isAdmin) return true; // Admin a toutes les permissions
    return permissions.contains(permission);
  }

  UserRoleEntity copyWith({
    UserRoleType? roleType,
    DateTime? assignedAt,
    String? assignedBy,
    bool? isActive,
    List<String>? permissions,
  }) {
    return UserRoleEntity(
      roleType: roleType ?? this.roleType,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedBy: assignedBy ?? this.assignedBy,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
        roleType,
        assignedAt,
        assignedBy,
        isActive,
        permissions,
      ];
}
