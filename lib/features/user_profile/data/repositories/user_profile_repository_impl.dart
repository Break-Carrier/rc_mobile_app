import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/entities/soft_deletable_entity.dart';
import '../../../../core/services/audit_service.dart';

/// Implémentation Firebase du repository UserProfile
///
/// Gère la persistance des profils utilisateur avec support
/// du soft delete et de l'audit trail.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remoteDataSource;
  final AuditService _auditService;

  const UserProfileRepositoryImpl(
    this._remoteDataSource,
    this._auditService,
  );

  @override
  Future<UserProfileResult<UserProfileEntity>> getUserProfile(
      String userId) async {
    try {
      // Récupération depuis Firebase
      final profileModel = await _remoteDataSource.getUserProfile(userId);

      if (profileModel == null) {
        return UserProfileFailure(
          const DataNotFoundError(
            message: 'Profil utilisateur introuvable',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      // Conversion Model -> Entity
      final entity = profileModel.toEntity();
      return UserProfileSuccess(entity);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> getAllBeekeepers({
    bool includeInactive = false,
  }) async {
    try {
      final profileModels = await _remoteDataSource.getAllBeekeepers(
        includeInactive: includeInactive,
      );

      final entities = profileModels.map((model) => model.toEntity()).toList();

      return UserProfileSuccess(entities);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>>
      getPendingBeekeepers() async {
    try {
      final profileModels = await _remoteDataSource.getPendingBeekeepers();

      final entities = profileModels.map((model) => model.toEntity()).toList();

      return UserProfileSuccess(entities);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> createUserProfile(
    UserProfileEntity profile,
  ) async {
    try {
      // Conversion Entity -> Model
      final profileModel = UserProfileModel.fromEntity(profile);

      // Création dans Firebase
      final createdModel =
          await _remoteDataSource.createUserProfile(profileModel);

      // Audit log
      await _auditService.logSoftDeletion(
        entityType: 'UserProfile',
        entityId: profile.userId,
        performedBy: profile.createdBy ?? 'system',
        reason: 'Création de profil utilisateur',
      );

      final entity = createdModel.toEntity();
      return UserProfileSuccess(entity);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> updateUserProfile(
    UserProfileEntity profile,
  ) async {
    try {
      // Vérification de la version pour la concurrence optimiste
      final existingResult = await getUserProfile(profile.userId);
      if (existingResult is UserProfileFailure) {
        return existingResult;
      }

      final existingProfile = (existingResult as UserProfileSuccess).data;
      if (existingProfile.version != profile.version) {
        return UserProfileFailure(
          const ValidationError(
            message:
                'Le profil a été modifié par un autre utilisateur. Veuillez actualiser.',
            code: 'CONCURRENT_MODIFICATION',
          ),
        );
      }

      // Incrémentation de version
      final updatedProfile = profile.copyWith(
        version: profile.version + 1,
        updatedAt: DateTime.now(),
      );

      // Conversion et mise à jour
      final profileModel = UserProfileModel.fromEntity(updatedProfile);
      final updatedModel =
          await _remoteDataSource.updateUserProfile(profileModel);

      final entity = updatedModel.toEntity();
      return UserProfileSuccess(entity);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> softDeleteUserProfile(
    String userId,
    DeletionInfo deletionInfo,
  ) async {
    try {
      // Récupération du profil existant
      final existingResult = await getUserProfile(userId);
      if (existingResult is UserProfileFailure) {
        return existingResult;
      }

      final existingProfile = (existingResult as UserProfileSuccess).data;

      // Création du profil supprimé
      final deletedProfile = existingProfile.copyWith(
        isDeleted: true,
        deletedAt: deletionInfo.effectiveDeletionDate,
        deletedBy: deletionInfo.deletedBy,
        deletionReason: deletionInfo.reason,
        version: existingProfile.version + 1,
        updatedAt: DateTime.now(),
        updatedBy: deletionInfo.deletedBy,
      );

      // Mise à jour dans Firebase
      final profileModel = UserProfileModel.fromEntity(deletedProfile);
      final updatedModel =
          await _remoteDataSource.updateUserProfile(profileModel);

      // Audit log
      await _auditService.logSoftDeletion(
        entityType: 'UserProfile',
        entityId: userId,
        performedBy: deletionInfo.deletedBy,
        reason: deletionInfo.reason,
        additionalData: deletionInfo.metadata,
      );

      final entity = updatedModel.toEntity();
      return UserProfileSuccess(entity);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> restoreUserProfile(
    String userId,
    RestorationInfo restorationInfo,
  ) async {
    try {
      // Récupération du profil supprimé
      final existingResult = await getUserProfile(userId);
      if (existingResult is UserProfileFailure) {
        return existingResult;
      }

      final existingProfile = (existingResult as UserProfileSuccess).data;

      // Création du profil restauré
      final restoredProfile = existingProfile.copyWith(
        isDeleted: false,
        deletedAt: null,
        deletedBy: null,
        deletionReason: null,
        version: existingProfile.version + 1,
        updatedAt: DateTime.now(),
        updatedBy: restorationInfo.restoredBy,
      );

      // Mise à jour dans Firebase
      final profileModel = UserProfileModel.fromEntity(restoredProfile);
      final updatedModel =
          await _remoteDataSource.updateUserProfile(profileModel);

      // Audit log
      await _auditService.logRestoration(
        entityType: 'UserProfile',
        entityId: userId,
        performedBy: restorationInfo.restoredBy,
        reason: restorationInfo.reason,
        additionalData: restorationInfo.metadata,
      );

      final entity = updatedModel.toEntity();
      return UserProfileSuccess(entity);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> getDeletedProfiles({
    bool includeExpired = false,
    Duration? maxAge,
  }) async {
    try {
      final profileModels = await _remoteDataSource.getDeletedProfiles(
        includeExpired: includeExpired,
        maxAge: maxAge,
      );

      final entities = profileModels.map((model) => model.toEntity()).toList();

      return UserProfileSuccess(entities);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<void>> permanentDeleteUserProfile(
    String userId,
    String deletedBy,
    String reason,
  ) async {
    try {
      // Récupération pour audit avant suppression
      final existingResult = await getUserProfile(userId);
      final existingProfile =
          existingResult is UserProfileSuccess ? existingResult.data : null;

      // Suppression définitive dans Firebase
      await _remoteDataSource.permanentDeleteUserProfile(userId);

      // Audit log critique
      await _auditService.logPermanentDeletion(
        entityType: 'UserProfile',
        entityId: userId,
        performedBy: deletedBy,
        reason: reason,
        additionalData: existingProfile != null
            ? {
                'profile_backup': {
                  'fullName': existingProfile.fullName,
                  'email': existingProfile.email,
                  'role': existingProfile.role.roleType.value,
                  'deletedAt': existingProfile.deletedAt?.toIso8601String(),
                }
              }
            : null,
      );

      return const UserProfileSuccess(null);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> updateUserRole(
    String userId,
    UserRoleEntity newRole,
    String updatedBy,
  ) async {
    try {
      // Récupération du profil existant
      final existingResult = await getUserProfile(userId);
      if (existingResult is UserProfileFailure) {
        return existingResult;
      }

      final existingProfile = (existingResult as UserProfileSuccess).data;
      final oldRole = existingProfile.role;

      // Mise à jour avec nouveau rôle
      final updatedProfile = existingProfile.copyWith(
        role: newRole,
        version: existingProfile.version + 1,
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );

      // Sauvegarde
      final updateResult = await updateUserProfile(updatedProfile);

      // Audit log spécifique au changement de rôle
      if (updateResult is UserProfileSuccess) {
        await _auditService.logSoftDeletion(
          entityType: 'UserProfile',
          entityId: userId,
          performedBy: updatedBy,
          reason: 'Changement de rôle utilisateur',
          additionalData: {
            'old_role': oldRole.roleType.value,
            'new_role': newRole.roleType.value,
          },
        );
      }

      return updateResult;
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> validateBeekeeper(
    String userId,
    bool approved,
    String adminId, {
    String? comments,
  }) async {
    try {
      // Récupération du profil
      final existingResult = await getUserProfile(userId);
      if (existingResult is UserProfileFailure) {
        return existingResult;
      }

      final existingProfile = (existingResult as UserProfileSuccess).data;

      // Nouveau statut de validation
      final newValidationStatus = approved
          ? BeekeeperValidationStatus.approved
          : BeekeeperValidationStatus.rejected;

      // Nouveau type de rôle
      final newRoleType =
          approved ? UserRoleType.beekeeper : UserRoleType.pendingBeekeeper;

      // Mise à jour du rôle
      final updatedRole = existingProfile.role.copyWith(
        roleType: newRoleType,
      );

      // Mise à jour des détails apiculteur si présents
      BeekeeperDetailsEntity? updatedBeekeeperDetails;
      if (existingProfile.beekeeperDetails != null) {
        updatedBeekeeperDetails = existingProfile.beekeeperDetails!.copyWith(
          validationStatus: newValidationStatus,
          validatedAt: approved ? DateTime.now() : null,
          adminComments: comments,
        );
      }

      // Profil mis à jour
      final updatedProfile = existingProfile.copyWith(
        role: updatedRole,
        beekeeperDetails: updatedBeekeeperDetails,
        version: existingProfile.version + 1,
        updatedAt: DateTime.now(),
        updatedBy: adminId,
      );

      // Sauvegarde
      final updateResult = await updateUserProfile(updatedProfile);

      // Audit log
      if (updateResult is UserProfileSuccess) {
        await _auditService.logSoftDeletion(
          entityType: 'UserProfile',
          entityId: userId,
          performedBy: adminId,
          reason: approved
              ? 'Validation apiculteur approuvée'
              : 'Validation apiculteur rejetée',
          additionalData: {
            'approved': approved,
            'comments': comments,
            'validation_status': newValidationStatus.value,
          },
        );
      }

      return updateResult;
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> deactivateUserProfile(
    String userId,
    String deactivatedBy,
    String reason,
  ) async {
    // Utilise le soft delete avec une raison spécifique
    return await softDeleteUserProfile(
      userId,
      DeletionInfo(
        deletedBy: deactivatedBy,
        reason: 'Désactivation: $reason',
        metadata: {'action_type': 'deactivation'},
      ),
    );
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> reactivateUserProfile(
    String userId,
    String reactivatedBy,
  ) async {
    // Utilise la restauration avec une raison spécifique
    return await restoreUserProfile(
      userId,
      RestorationInfo(
        restoredBy: reactivatedBy,
        reason: 'Réactivation du profil utilisateur',
        metadata: {'action_type': 'reactivation'},
      ),
    );
  }

  @override
  Future<UserProfileResult<bool>> isEmailAlreadyUsed(
    String email, {
    String? excludeUserId,
  }) async {
    try {
      final isUsed = await _remoteDataSource.isEmailAlreadyUsed(
        email,
        excludeUserId: excludeUserId,
      );

      return UserProfileSuccess(isUsed);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> searchUsers(
    String searchTerm, {
    UserRoleType? roleFilter,
    bool? statusFilter,
  }) async {
    try {
      final profileModels = await _remoteDataSource.searchUsers(
        searchTerm,
        roleFilter: roleFilter,
        statusFilter: statusFilter,
      );

      final entities = profileModels.map((model) => model.toEntity()).toList();

      return UserProfileSuccess(entities);
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }
}
