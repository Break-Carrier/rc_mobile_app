import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_role_entity.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/entities/soft_deletable_entity.dart';

/// Implémentation temporaire du repository UserProfile
///
/// Cette implémentation retourne des erreurs "non implémenté" pour permettre
/// au système de démarrer. Elle sera remplacée par une vraie implémentation.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  UserProfileResult<T> _notImplemented<T>(String methodName) {
    return UserProfileFailure(
      ServiceError(
        message:
            'Méthode $methodName non implémentée - implémentation temporaire',
        code: 'NOT_IMPLEMENTED',
        originalError: null,
      ),
    );
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> getUserProfile(
      String userId) async {
    return _notImplemented<UserProfileEntity>('getUserProfile');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> createUserProfile(
      UserProfileEntity profile) async {
    return _notImplemented<UserProfileEntity>('createUserProfile');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> updateUserRole(
      String userId, UserRoleEntity role, String updatedBy) async {
    return _notImplemented<UserProfileEntity>('updateUserRole');
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> getAllBeekeepers(
      {bool includeInactive = false}) async {
    return _notImplemented<List<UserProfileEntity>>('getAllBeekeepers');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> updateUserProfile(
      UserProfileEntity profile) async {
    return _notImplemented<UserProfileEntity>('updateUserProfile');
  }

  @override
  Future<UserProfileResult<void>> deleteUserProfile(String userId) async {
    return _notImplemented<void>('deleteUserProfile');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> deactivateUserProfile(
      String userId, String deactivatedBy, String reason) async {
    return _notImplemented<UserProfileEntity>('deactivateUserProfile');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> reactivateUserProfile(
      String userId, String reactivatedBy) async {
    return _notImplemented<UserProfileEntity>('reactivateUserProfile');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> softDeleteUserProfile(
      String userId, DeletionInfo deletionInfo) async {
    return _notImplemented<UserProfileEntity>('softDeleteUserProfile');
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> getDeletedProfiles({
    bool includeExpired = false,
    Duration? maxAge,
  }) async {
    return _notImplemented<List<UserProfileEntity>>('getDeletedProfiles');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> restoreUserProfile(
      String userId, RestorationInfo restorationInfo) async {
    return _notImplemented<UserProfileEntity>('restoreUserProfile');
  }

  @override
  Future<UserProfileResult<void>> permanentDeleteUserProfile(
      String userId, String deletedBy, String reason) async {
    return _notImplemented<void>('permanentDeleteUserProfile');
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>>
      getPendingBeekeepers() async {
    return _notImplemented<List<UserProfileEntity>>('getPendingBeekeepers');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> validateBeekeeper(
      String userId, bool approved, String adminId,
      {String? comments}) async {
    return _notImplemented<UserProfileEntity>('validateBeekeeper');
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> rejectBeekeeper(
      String userId, String rejectedBy, String rejectionReason) async {
    return _notImplemented<UserProfileEntity>('rejectBeekeeper');
  }

  @override
  Future<UserProfileResult<bool>> isEmailAlreadyUsed(String email,
      {String? excludeUserId}) async {
    return _notImplemented<bool>('isEmailAlreadyUsed');
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> searchUsers(
      String searchTerm,
      {UserRoleType? roleFilter,
      bool? statusFilter}) async {
    return _notImplemented<List<UserProfileEntity>>('searchUsers');
  }
}
