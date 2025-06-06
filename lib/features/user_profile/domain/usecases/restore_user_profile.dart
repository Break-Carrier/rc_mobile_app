import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/entities/soft_deletable_entity.dart';

/// Use case pour restaurer un profil utilisateur supprimé logiquement
///
/// Permet de restaurer des données supprimées en cas de réclamation
/// ou d'erreur de manipulation.
class RestoreUserProfile {
  final UserProfileRepository _repository;

  const RestoreUserProfile(this._repository);

  /// Restaure un profil utilisateur supprimé logiquement
  ///
  /// [userId] - ID de l'utilisateur à restaurer
  /// [restoredBy] - ID de l'utilisateur effectuant la restauration
  /// [reason] - Raison de la restauration
  /// [metadata] - Métadonnées additionnelles (optionnelles)
  ///
  /// Valide les permissions et l'état avant restauration
  Future<UserProfileResult<UserProfileEntity>> call({
    required String userId,
    required String restoredBy,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    // Validation des paramètres
    final validationError = _validateParameters(userId, restoredBy, reason);
    if (validationError != null) {
      return UserProfileFailure(validationError);
    }

    try {
      // Vérification que l'utilisateur existe et est supprimé
      final existingProfileResult = await _repository.getUserProfile(userId);

      if (existingProfileResult is UserProfileFailure) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Impossible de trouver le profil utilisateur à restaurer',
            code: 'PROFILE_NOT_FOUND_FOR_RESTORATION',
          ),
        );
      }

      final existingProfile =
          (existingProfileResult as UserProfileSuccess).data;

      // Vérification si le profil est supprimé
      if (!existingProfile.isDeleted) {
        return UserProfileFailure(
          const ValidationError(
            message:
                'Ce profil utilisateur n\'est pas supprimé et ne peut pas être restauré',
            code: 'NOT_DELETED',
          ),
        );
      }

      // Vérification si la restauration est encore possible
      final restorationError = _checkRestorationEligibility(existingProfile);
      if (restorationError != null) {
        return UserProfileFailure(restorationError);
      }

      // Vérification des permissions pour la restauration
      final permissionError =
          await _checkRestorationPermissions(existingProfile, restoredBy);
      if (permissionError != null) {
        return UserProfileFailure(permissionError);
      }

      // Création des informations de restauration
      final restorationInfo = RestorationInfo(
        restoredBy: restoredBy,
        reason: reason,
        metadata: metadata,
      );

      // Restauration via le repository
      return await _repository.restoreUserProfile(userId, restorationInfo);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  /// Valide les paramètres d'entrée
  ValidationError? _validateParameters(
      String userId, String restoredBy, String reason) {
    if (userId.isEmpty) {
      return const ValidationError(
        message: 'L\'identifiant utilisateur ne peut pas être vide',
        code: 'EMPTY_USER_ID',
      );
    }

    if (restoredBy.isEmpty) {
      return const ValidationError(
        message:
            'L\'identifiant de l\'utilisateur effectuant la restauration est requis',
        code: 'EMPTY_RESTORED_BY',
      );
    }

    if (reason.trim().isEmpty) {
      return const ValidationError(
        message: 'Une raison de restauration est obligatoire',
        code: 'EMPTY_RESTORATION_REASON',
      );
    }

    if (reason.length < 10) {
      return const ValidationError(
        message:
            'La raison de restauration doit être plus détaillée (minimum 10 caractères)',
        code: 'RESTORATION_REASON_TOO_SHORT',
      );
    }

    return null;
  }

  /// Vérifie si la restauration est encore possible
  ValidationError? _checkRestorationEligibility(UserProfileEntity profile) {
    // Vérification de la période de grâce pour la restauration
    const maxRestorationPeriod = Duration(days: 90); // 3 mois par défaut

    if (!profile.isRecentlyDeleted(maxRestorationPeriod)) {
      return ValidationError(
        message:
            'La période de restauration est expirée (${maxRestorationPeriod.inDays} jours maximum)',
        code: 'RESTORATION_PERIOD_EXPIRED',
      );
    }

    // Vérification que le profil peut être restauré
    if (!profile.canBeRestored) {
      return const ValidationError(
        message: 'Ce profil ne peut pas être restauré',
        code: 'RESTORATION_NOT_ALLOWED',
      );
    }

    return null;
  }

  /// Vérifie les permissions pour la restauration
  Future<ValidationError?> _checkRestorationPermissions(
    UserProfileEntity targetProfile,
    String restoredBy,
  ) async {
    try {
      // Récupération du profil de l'utilisateur effectuant la restauration
      final restorerProfileResult =
          await _repository.getUserProfile(restoredBy);

      if (restorerProfileResult is UserProfileFailure) {
        return const ValidationError(
          message: 'Impossible de vérifier les permissions de restauration',
          code: 'PERMISSION_CHECK_FAILED',
        );
      }

      final restorerProfile =
          (restorerProfileResult as UserProfileSuccess).data;

      // Seuls les administrateurs peuvent restaurer des profils
      if (!restorerProfile.isAdmin) {
        return const ValidationError(
          message:
              'Seuls les administrateurs peuvent restaurer des profils utilisateur',
          code: 'INSUFFICIENT_PERMISSIONS',
        );
      }

      // Vérification que l'administrateur n'est pas lui-même supprimé
      if (restorerProfile.isDeleted) {
        return const ValidationError(
          message:
              'Un administrateur supprimé ne peut pas effectuer de restaurations',
          code: 'RESTORER_IS_DELETED',
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
}

/// Use case pour récupérer les profils supprimés (pour les administrateurs)
class GetDeletedProfiles {
  final UserProfileRepository _repository;

  const GetDeletedProfiles(this._repository);

  /// Récupère la liste des profils supprimés
  ///
  /// [requestedBy] - ID de l'utilisateur demandant la liste
  /// [includeExpired] - Inclure les suppressions expirées
  /// [maxAge] - Âge maximum des suppressions à inclure
  Future<UserProfileResult<List<UserProfileEntity>>> call({
    required String requestedBy,
    bool includeExpired = false,
    Duration? maxAge,
  }) async {
    // Validation des paramètres
    if (requestedBy.isEmpty) {
      return UserProfileFailure(
        const ValidationError(
          message: 'L\'identifiant de l\'utilisateur demandeur est requis',
          code: 'EMPTY_REQUESTED_BY',
        ),
      );
    }

    try {
      // Vérification des permissions
      final permissionError = await _checkViewPermissions(requestedBy);
      if (permissionError != null) {
        return UserProfileFailure(permissionError);
      }

      // Récupération des profils supprimés
      return await _repository.getDeletedProfiles(
        includeExpired: includeExpired,
        maxAge: maxAge,
      );
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  /// Vérifie les permissions pour consulter les profils supprimés
  Future<ValidationError?> _checkViewPermissions(String requestedBy) async {
    try {
      final requesterProfileResult =
          await _repository.getUserProfile(requestedBy);

      if (requesterProfileResult is UserProfileFailure) {
        return const ValidationError(
          message: 'Impossible de vérifier les permissions',
          code: 'PERMISSION_CHECK_FAILED',
        );
      }

      final requesterProfile =
          (requesterProfileResult as UserProfileSuccess).data;

      if (!requesterProfile.isAdmin) {
        return const ValidationError(
          message:
              'Seuls les administrateurs peuvent consulter les profils supprimés',
          code: 'INSUFFICIENT_PERMISSIONS',
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
}
