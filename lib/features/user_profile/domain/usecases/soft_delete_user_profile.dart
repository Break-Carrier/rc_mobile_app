import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/entities/soft_deletable_entity.dart';

/// Use case pour la suppression logique d'un profil utilisateur
///
/// Gère la suppression "soft" qui permet la récupération ultérieure
/// des données en cas de réclamation ou d'erreur.
class SoftDeleteUserProfile {
  final UserProfileRepository _repository;

  const SoftDeleteUserProfile(this._repository);

  /// Supprime logiquement un profil utilisateur
  ///
  /// [userId] - ID de l'utilisateur à supprimer
  /// [deletedBy] - ID de l'utilisateur effectuant la suppression
  /// [reason] - Raison de la suppression
  /// [metadata] - Métadonnées additionnelles (optionnelles)
  ///
  /// Valide les permissions et les paramètres avant suppression
  Future<UserProfileResult<UserProfileEntity>> call({
    required String userId,
    required String deletedBy,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    // Validation des paramètres
    final validationError = _validateParameters(userId, deletedBy, reason);
    if (validationError != null) {
      return UserProfileFailure(validationError);
    }

    try {
      // Vérification que l'utilisateur existe et n'est pas déjà supprimé
      final existingProfileResult = await _repository.getUserProfile(userId);

      if (existingProfileResult is UserProfileFailure) {
        return existingProfileResult;
      }

      final existingProfile =
          (existingProfileResult as UserProfileSuccess).data;

      // Vérification si déjà supprimé
      if (existingProfile.isDeleted) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Ce profil utilisateur est déjà supprimé',
            code: 'ALREADY_DELETED',
          ),
        );
      }

      // Vérification des permissions pour la suppression
      final permissionError =
          await _checkDeletionPermissions(existingProfile, deletedBy);
      if (permissionError != null) {
        return UserProfileFailure(permissionError);
      }

      // Création des informations de suppression
      final deletionInfo = DeletionInfo(
        deletedBy: deletedBy,
        reason: reason,
        metadata: metadata,
      );

      // Suppression logique via le repository
      return await _repository.softDeleteUserProfile(userId, deletionInfo);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  /// Valide les paramètres d'entrée
  ValidationError? _validateParameters(
      String userId, String deletedBy, String reason) {
    if (userId.isEmpty) {
      return const ValidationError(
        message: 'L\'identifiant utilisateur ne peut pas être vide',
        code: 'EMPTY_USER_ID',
      );
    }

    if (deletedBy.isEmpty) {
      return const ValidationError(
        message:
            'L\'identifiant de l\'utilisateur effectuant la suppression est requis',
        code: 'EMPTY_DELETED_BY',
      );
    }

    if (reason.trim().isEmpty) {
      return const ValidationError(
        message: 'Une raison de suppression est obligatoire',
        code: 'EMPTY_DELETION_REASON',
      );
    }

    if (reason.length < 10) {
      return const ValidationError(
        message:
            'La raison de suppression doit être plus détaillée (minimum 10 caractères)',
        code: 'DELETION_REASON_TOO_SHORT',
      );
    }

    if (userId == deletedBy) {
      return const ValidationError(
        message: 'Un utilisateur ne peut pas supprimer son propre profil',
        code: 'SELF_DELETION_NOT_ALLOWED',
      );
    }

    return null;
  }

  /// Vérifie les permissions pour la suppression
  Future<ValidationError?> _checkDeletionPermissions(
    UserProfileEntity targetProfile,
    String deletedBy,
  ) async {
    try {
      // Récupération du profil de l'utilisateur effectuant la suppression
      final deleterProfileResult = await _repository.getUserProfile(deletedBy);

      if (deleterProfileResult is UserProfileFailure) {
        return const ValidationError(
          message: 'Impossible de vérifier les permissions de suppression',
          code: 'PERMISSION_CHECK_FAILED',
        );
      }

      final deleterProfile = (deleterProfileResult as UserProfileSuccess).data;

      // Seuls les administrateurs peuvent supprimer des profils
      if (!deleterProfile.isAdmin) {
        return const ValidationError(
          message:
              'Seuls les administrateurs peuvent supprimer des profils utilisateur',
          code: 'INSUFFICIENT_PERMISSIONS',
        );
      }

      // Un administrateur ne peut pas supprimer un autre administrateur
      // sauf si c'est un super-admin (logique métier à adapter selon besoins)
      if (targetProfile.isAdmin && !_isSuperAdmin(deleterProfile)) {
        return const ValidationError(
          message: 'Impossible de supprimer un profil administrateur',
          code: 'CANNOT_DELETE_ADMIN',
        );
      }

      return null;
    } catch (e) {
      return const ValidationError(
        message: 'Erreur lors de la vérification des permissions',
        code: 'PERMISSION_CHECK_ERROR',
      );
    }
  }

  /// Vérifie si l'utilisateur est super-administrateur
  /// À adapter selon la logique métier spécifique
  bool _isSuperAdmin(UserProfileEntity profile) {
    // Logique à implémenter selon vos besoins :
    // - Vérification de permissions spéciales
    // - Vérification d'un rôle super-admin
    // - Vérification dans une liste de super-admins
    return false; // Placeholder
  }
}
