import '../../../../core/error/app_error.dart';
import '../../../../core/entities/soft_deletable_entity.dart';
import '../entities/user_profile_entity.dart';
import '../entities/user_role_entity.dart';

/// Résultat d'une opération avec gestion d'erreur
sealed class UserProfileResult<T> {
  const UserProfileResult();
}

/// Succès d'une opération
class UserProfileSuccess<T> extends UserProfileResult<T> {
  final T data;
  const UserProfileSuccess(this.data);
}

/// Échec d'une opération
class UserProfileFailure<T> extends UserProfileResult<T> {
  final AppError error;
  const UserProfileFailure(this.error);
}

/// Interface du repository pour la gestion des profils utilisateur
///
/// Définit les contrats pour les opérations sur les profils utilisateur
/// suivant les principes de Clean Architecture.
abstract class UserProfileRepository {
  /// Récupère le profil complet d'un utilisateur par son ID
  ///
  /// [userId] - Identifiant unique de l'utilisateur (Firebase UID)
  ///
  /// Retourne soit le profil utilisateur, soit une erreur
  Future<UserProfileResult<UserProfileEntity>> getUserProfile(String userId);

  /// Récupère tous les profils d'apiculteurs (pour les administrateurs)
  ///
  /// [includeInactive] - Inclure les profils inactifs dans les résultats
  ///
  /// Retourne la liste des profils d'apiculteurs ou une erreur
  Future<UserProfileResult<List<UserProfileEntity>>> getAllBeekeepers({
    bool includeInactive = false,
  });

  /// Récupère les apiculteurs en attente de validation
  ///
  /// Retourne la liste des profils en attente ou une erreur
  Future<UserProfileResult<List<UserProfileEntity>>> getPendingBeekeepers();

  /// Crée un nouveau profil utilisateur
  ///
  /// [profile] - Profil utilisateur à créer
  ///
  /// Retourne le profil créé ou une erreur
  Future<UserProfileResult<UserProfileEntity>> createUserProfile(
    UserProfileEntity profile,
  );

  /// Met à jour un profil utilisateur existant
  ///
  /// [profile] - Profil utilisateur avec les nouvelles données
  ///
  /// Retourne le profil mis à jour ou une erreur
  Future<UserProfileResult<UserProfileEntity>> updateUserProfile(
    UserProfileEntity profile,
  );

  /// Met à jour le rôle d'un utilisateur (pour les administrateurs)
  ///
  /// [userId] - Identifiant de l'utilisateur
  /// [newRole] - Nouveau rôle à attribuer
  /// [updatedBy] - ID de l'administrateur effectuant la modification
  ///
  /// Retourne le profil mis à jour ou une erreur
  Future<UserProfileResult<UserProfileEntity>> updateUserRole(
    String userId,
    UserRoleEntity newRole,
    String updatedBy,
  );

  /// Valide ou rejette un apiculteur en attente
  ///
  /// [userId] - Identifiant de l'apiculteur
  /// [approved] - true pour approuver, false pour rejeter
  /// [adminId] - ID de l'administrateur effectuant l'action
  /// [comments] - Commentaires optionnels de l'administrateur
  ///
  /// Retourne le profil mis à jour ou une erreur
  Future<UserProfileResult<UserProfileEntity>> validateBeekeeper(
    String userId,
    bool approved,
    String adminId, {
    String? comments,
  });

  /// Désactive un profil utilisateur
  ///
  /// [userId] - Identifiant de l'utilisateur
  /// [deactivatedBy] - ID de l'administrateur effectuant l'action
  /// [reason] - Raison de la désactivation
  ///
  /// Retourne le profil désactivé ou une erreur
  Future<UserProfileResult<UserProfileEntity>> deactivateUserProfile(
    String userId,
    String deactivatedBy,
    String reason,
  );

  /// Réactive un profil utilisateur désactivé
  ///
  /// [userId] - Identifiant de l'utilisateur
  /// [reactivatedBy] - ID de l'administrateur effectuant l'action
  ///
  /// Retourne le profil réactivé ou une erreur
  Future<UserProfileResult<UserProfileEntity>> reactivateUserProfile(
    String userId,
    String reactivatedBy,
  );

  /// Supprime logiquement un profil utilisateur (soft delete)
  ///
  /// [userId] - Identifiant de l'utilisateur
  /// [deletionInfo] - Informations sur la suppression
  ///
  /// Retourne le profil supprimé ou une erreur
  Future<UserProfileResult<UserProfileEntity>> softDeleteUserProfile(
    String userId,
    DeletionInfo deletionInfo,
  );

  /// Restaure un profil utilisateur supprimé logiquement
  ///
  /// [userId] - Identifiant de l'utilisateur
  /// [restorationInfo] - Informations sur la restauration
  ///
  /// Retourne le profil restauré ou une erreur
  Future<UserProfileResult<UserProfileEntity>> restoreUserProfile(
    String userId,
    RestorationInfo restorationInfo,
  );

  /// Supprime définitivement un profil utilisateur
  ///
  /// ⚠️ Action irréversible - à utiliser avec précaution extrême
  /// Uniquement pour les cas de conformité légale ou de sécurité
  ///
  /// [userId] - Identifiant de l'utilisateur
  /// [deletedBy] - ID de l'administrateur effectuant l'action
  /// [reason] - Raison obligatoire de la suppression définitive
  ///
  /// Retourne void en cas de succès ou une erreur
  Future<UserProfileResult<void>> permanentDeleteUserProfile(
    String userId,
    String deletedBy,
    String reason,
  );

  /// Récupère les profils supprimés logiquement (pour les administrateurs)
  ///
  /// [includeExpired] - Inclure les suppressions anciennes
  /// [maxAge] - Âge maximum des suppressions à inclure
  ///
  /// Retourne la liste des profils supprimés ou une erreur
  Future<UserProfileResult<List<UserProfileEntity>>> getDeletedProfiles({
    bool includeExpired = false,
    Duration? maxAge,
  });

  /// Vérifie si un email est déjà utilisé
  ///
  /// [email] - Adresse email à vérifier
  /// [excludeUserId] - ID utilisateur à exclure de la vérification (pour les mises à jour)
  ///
  /// Retourne true si l'email existe déjà, false sinon
  Future<UserProfileResult<bool>> isEmailAlreadyUsed(
    String email, {
    String? excludeUserId,
  });

  /// Recherche des utilisateurs par critères
  ///
  /// [searchTerm] - Terme de recherche (nom, email, etc.)
  /// [roleFilter] - Filtre par rôle (optionnel)
  /// [statusFilter] - Filtre par statut (actif/inactif)
  ///
  /// Retourne la liste des profils correspondants ou une erreur
  Future<UserProfileResult<List<UserProfileEntity>>> searchUsers(
    String searchTerm, {
    UserRoleType? roleFilter,
    bool? statusFilter,
  });
}
