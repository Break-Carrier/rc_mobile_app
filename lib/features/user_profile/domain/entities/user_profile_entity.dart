import 'user_role_entity.dart';
import 'beekeeper_details_entity.dart';
import '../../../../core/entities/soft_deletable_entity.dart';

/// Entité représentant le profil complet d'un utilisateur
///
/// Cette entité combine les informations d'authentification de base
/// avec les données métier étendues (rôle, informations personnelles,
/// détails spécifiques au métier d'apiculteur).
///
/// Hérite de SoftDeletableEntity pour supporter la suppression logique.
class UserProfileEntity extends SoftDeletableEntity {
  /// Identifiant unique (Firebase UID)
  final String userId;

  /// Informations personnelles de base
  final String firstName;
  final String lastName;
  final String email;

  /// Informations d'adresse
  final String address;
  final String? city;
  final String? postalCode;
  final String? country;

  /// Rôle et permissions
  final UserRoleEntity role;

  /// Détails spécifiques apiculteur (null si pas apiculteur)
  final BeekeeperDetailsEntity? beekeeperDetails;

  /// Statut du profil
  final bool isEmailVerified;

  /// Photo de profil (URL)
  final String? profileImageUrl;

  /// Numéro de téléphone (optionnel)
  final String? phoneNumber;

  const UserProfileEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.role,
    this.city,
    this.postalCode,
    this.country,
    this.beekeeperDetails,
    this.isEmailVerified = false,
    this.profileImageUrl,
    this.phoneNumber,
    // Paramètres de SoftDeletableEntity
    super.isDeleted,
    super.deletedAt,
    super.deletedBy,
    super.deletionReason,
    super.version,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  /// Nom complet formaté
  String get fullName => '$firstName $lastName';

  /// Adresse complète formatée
  String get fullAddress {
    final parts = [address];
    if (city != null) parts.add(city!);
    if (postalCode != null) parts.add(postalCode!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  /// Vérifie si l'utilisateur est un administrateur
  bool get isAdmin => role.isAdmin;

  /// Vérifie si l'utilisateur est un apiculteur validé
  bool get isValidatedBeekeeper => role.isValidatedBeekeeper;

  /// Vérifie si l'utilisateur est en attente de validation
  bool get isPendingValidation => role.isPendingValidation;

  /// Vérifie si le profil est complet
  bool get isProfileComplete {
    final basicInfoComplete = firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        address.isNotEmpty;

    if (role.roleType == UserRoleType.beekeeper) {
      return basicInfoComplete && beekeeperDetails != null;
    }

    return basicInfoComplete;
  }

  /// Vérifie si l'utilisateur peut accéder aux fonctionnalités d'apiculture
  bool get canAccessBeekeepingFeatures => isValidatedBeekeeper || isAdmin;

  /// Vérifie si l'utilisateur peut gérer d'autres utilisateurs
  bool get canManageUsers => isAdmin;

  UserProfileEntity copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    UserRoleEntity? role,
    BeekeeperDetailsEntity? beekeeperDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    String? deletionReason,
    int? version,
    String? createdBy,
    String? updatedBy,
    bool? isEmailVerified,
    String? profileImageUrl,
    String? phoneNumber,
  }) {
    return UserProfileEntity(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      role: role ?? this.role,
      beekeeperDetails: beekeeperDetails ?? this.beekeeperDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      deletionReason: deletionReason ?? this.deletionReason,
      version: version ?? this.version,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        email,
        address,
        city,
        postalCode,
        country,
        role,
        beekeeperDetails,
        createdAt,
        updatedAt,
        isActive,
        isEmailVerified,
        profileImageUrl,
        phoneNumber,
      ];
}
