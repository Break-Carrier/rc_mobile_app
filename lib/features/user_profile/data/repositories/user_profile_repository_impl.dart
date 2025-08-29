import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_role_entity.dart';
import '../../domain/entities/beekeeper_details_entity.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/entities/soft_deletable_entity.dart';

/// Implémentation complète du repository UserProfile avec Firebase Firestore
///
/// Respecte les règles de sécurité définies dans database.rules.json
/// Gère les rôles utilisateur et les permissions d'accès
class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // === Collections Firestore ===
  static const String _usersCollection = 'users';
  static const String _adminCollection = 'admin';
  static const String _auditLogsCollection = 'audit_logs';

  @override
  Future<UserProfileResult<UserProfileEntity>> getUserProfile(
      String userId) async {
    try {
      if (userId.isEmpty) {
        return UserProfileFailure(
          const ValidationError(
            message: 'L\'ID utilisateur ne peut pas être vide',
            code: 'EMPTY_USER_ID',
          ),
        );
      }

      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final data = docSnapshot.data()!;
      final profile = _mapDocumentToUserProfile(docSnapshot.id, data);

      return UserProfileSuccess(profile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la récupération du profil: ${error.toString()}',
          code: 'GET_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> createUserProfile(
      UserProfileEntity profile) async {
    try {
      _validateUserProfile(profile);

      // Vérification que l'email n'est pas déjà utilisé
      final emailCheckResult = await isEmailAlreadyUsed(profile.email);
      if (emailCheckResult is UserProfileSuccess) {
        final isUsed = (emailCheckResult as UserProfileSuccess<bool>).data;
        if (isUsed) {
          return UserProfileFailure(
            const ValidationError(
              message: 'Cette adresse email est déjà utilisée',
              code: 'EMAIL_ALREADY_USED',
            ),
          );
        }
      }

      final docRef =
          _firestore.collection(_usersCollection).doc(profile.userId);
      final data = _mapUserProfileToDocument(profile);

      await docRef.set(data);

      // Log de création pour audit
      await _logUserAction(
        action: 'CREATE_USER_PROFILE',
        userId: profile.userId,
        performedBy: profile.createdBy ?? 'SYSTEM',
        metadata: {'email': profile.email, 'role': profile.role.roleType.value},
      );

      return UserProfileSuccess(profile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message: 'Erreur lors de la création du profil: ${error.toString()}',
          code: 'CREATE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> updateUserRole(
      String userId, UserRoleEntity role, String updatedBy) async {
    try {
      if (userId.isEmpty || updatedBy.isEmpty) {
        return UserProfileFailure(
          const ValidationError(
            message:
                'L\'ID utilisateur et l\'ID de mise à jour ne peuvent pas être vides',
            code: 'EMPTY_IDS',
          ),
        );
      }

      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final currentData = docSnapshot.data()!;
      final currentProfile =
          _mapDocumentToUserProfile(docSnapshot.id, currentData);

      // Mise à jour du rôle
      final updatedProfile = currentProfile.copyWith(
        role: role,
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );

      final updateData = {
        'role': _mapUserRoleToDocument(role),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': updatedBy,
        'version': FieldValue.increment(1),
      };

      await docRef.update(updateData);

      // Log de mise à jour pour audit
      await _logUserAction(
        action: 'UPDATE_USER_ROLE',
        userId: userId,
        performedBy: updatedBy,
        metadata: {
          'oldRole': currentProfile.role.roleType.value,
          'newRole': role.roleType.value,
          'assignedBy': role.assignedBy,
        },
      );

      return UserProfileSuccess(updatedProfile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message: 'Erreur lors de la mise à jour du rôle: ${error.toString()}',
          code: 'UPDATE_USER_ROLE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> getAllBeekeepers(
      {bool includeInactive = false}) async {
    try {
      Query query = _firestore.collection(_usersCollection);

      // Filtrage par rôle (apiculteurs et admins)
      query = query.where('role.roleType', whereIn: [
        UserRoleType.beekeeper.value,
        UserRoleType.admin.value,
      ]);

      if (!includeInactive) {
        query = query.where('role.isActive', isEqualTo: true);
      }

      final querySnapshot = await query.get();
      final profiles = querySnapshot.docs
          .map((doc) => _mapDocumentToUserProfile(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return UserProfileSuccess(profiles);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la récupération des apiculteurs: ${error.toString()}',
          code: 'GET_ALL_BEEKEEPERS_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> updateUserProfile(
      UserProfileEntity profile) async {
    try {
      _validateUserProfile(profile);

      final docRef =
          _firestore.collection(_usersCollection).doc(profile.userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final data = _mapUserProfileToDocument(profile);
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['version'] = FieldValue.increment(1);

      await docRef.update(data);

      // Log de mise à jour pour audit
      await _logUserAction(
        action: 'UPDATE_USER_PROFILE',
        userId: profile.userId,
        performedBy: profile.userId, // Auto-mise à jour
        metadata: {'updatedFields': 'profile_data'},
      );

      return UserProfileSuccess(profile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la mise à jour du profil: ${error.toString()}',
          code: 'UPDATE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<void>> deleteUserProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        return UserProfileFailure(
          const ValidationError(
            message: 'L\'ID utilisateur ne peut pas être vide',
            code: 'EMPTY_USER_ID',
          ),
        );
      }

      final docRef = _firestore.collection(_usersCollection).doc(userId);
      await docRef.delete();

      // Log de suppression pour audit
      await _logUserAction(
        action: 'DELETE_USER_PROFILE',
        userId: userId,
        performedBy: 'SYSTEM',
        metadata: {'deletionType': 'hard_delete'},
      );

      return const UserProfileSuccess(null);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la suppression du profil: ${error.toString()}',
          code: 'DELETE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> deactivateUserProfile(
      String userId, String deactivatedBy, String reason) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final currentData = docSnapshot.data()!;
      final currentProfile =
          _mapDocumentToUserProfile(docSnapshot.id, currentData);

      // Désactivation du rôle
      final deactivatedRole = currentProfile.role.copyWith(isActive: false);
      final deactivatedProfile = currentProfile.copyWith(
        role: deactivatedRole,
        updatedAt: DateTime.now(),
        updatedBy: deactivatedBy,
      );

      await docRef.update({
        'role.isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': deactivatedBy,
        'version': FieldValue.increment(1),
      });

      // Log de désactivation pour audit
      await _logUserAction(
        action: 'DEACTIVATE_USER_PROFILE',
        userId: userId,
        performedBy: deactivatedBy,
        metadata: {'reason': reason},
      );

      return UserProfileSuccess(deactivatedProfile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la désactivation du profil: ${error.toString()}',
          code: 'DEACTIVATE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> reactivateUserProfile(
      String userId, String reactivatedBy) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final currentData = docSnapshot.data()!;
      final currentProfile =
          _mapDocumentToUserProfile(docSnapshot.id, currentData);

      // Réactivation du rôle
      final reactivatedRole = currentProfile.role.copyWith(isActive: true);
      final reactivatedProfile = currentProfile.copyWith(
        role: reactivatedRole,
        updatedAt: DateTime.now(),
        updatedBy: reactivatedBy,
      );

      await docRef.update({
        'role.isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': reactivatedBy,
        'version': FieldValue.increment(1),
      });

      // Log de réactivation pour audit
      await _logUserAction(
        action: 'REACTIVATE_USER_PROFILE',
        userId: userId,
        performedBy: reactivatedBy,
        metadata: {'reactivationType': 'manual'},
      );

      return UserProfileSuccess(reactivatedProfile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la réactivation du profil: ${error.toString()}',
          code: 'REACTIVATE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> softDeleteUserProfile(
      String userId, DeletionInfo deletionInfo) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final currentData = docSnapshot.data()!;
      final currentProfile =
          _mapDocumentToUserProfile(docSnapshot.id, currentData);

      // Soft delete avec métadonnées
      final softDeletedProfile = currentProfile.copyWith(
        isDeleted: true,
        deletedAt: deletionInfo.effectiveDeletionDate,
        deletedBy: deletionInfo.deletedBy,
        deletionReason: deletionInfo.reason,
        updatedAt: DateTime.now(),
      );

      await docRef.update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': deletionInfo.deletedBy,
        'deletionReason': deletionInfo.reason,
        'updatedAt': FieldValue.serverTimestamp(),
        'version': FieldValue.increment(1),
      });

      // Log de soft delete pour audit
      await _logUserAction(
        action: 'SOFT_DELETE_USER_PROFILE',
        userId: userId,
        performedBy: deletionInfo.deletedBy,
        metadata: {
          'reason': deletionInfo.reason,
          'metadata': deletionInfo.metadata,
        },
      );

      return UserProfileSuccess(softDeletedProfile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message: 'Erreur lors du soft delete du profil: ${error.toString()}',
          code: 'SOFT_DELETE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> getDeletedProfiles({
    bool includeExpired = false,
    Duration? maxAge,
  }) async {
    try {
      Query query = _firestore
          .collection(_usersCollection)
          .where('isDeleted', isEqualTo: true);

      if (!includeExpired && maxAge != null) {
        final cutoffDate = DateTime.now().subtract(maxAge);
        query = query.where('deletedAt', isGreaterThan: cutoffDate);
      }

      final querySnapshot = await query.get();
      final profiles = querySnapshot.docs
          .map((doc) => _mapDocumentToUserProfile(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return UserProfileSuccess(profiles);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la récupération des profils supprimés: ${error.toString()}',
          code: 'GET_DELETED_PROFILES_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> restoreUserProfile(
      String userId, RestorationInfo restorationInfo) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final currentData = docSnapshot.data()!;
      final currentProfile =
          _mapDocumentToUserProfile(docSnapshot.id, currentData);

      // Restauration du profil
      final restoredProfile = currentProfile.copyWith(
        isDeleted: false,
        deletedAt: null,
        deletedBy: null,
        deletionReason: null,
        updatedAt: DateTime.now(),
        updatedBy: restorationInfo.restoredBy,
      );

      await docRef.update({
        'isDeleted': false,
        'deletedAt': FieldValue.delete(),
        'deletedBy': FieldValue.delete(),
        'deletionReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': restorationInfo.restoredBy,
        'version': FieldValue.increment(1),
      });

      // Log de restauration pour audit
      await _logUserAction(
        action: 'RESTORE_USER_PROFILE',
        userId: userId,
        performedBy: restorationInfo.restoredBy,
        metadata: {'reason': restorationInfo.reason},
      );

      return UserProfileSuccess(restoredProfile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la restauration du profil: ${error.toString()}',
          code: 'RESTORE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<void>> permanentDeleteUserProfile(
      String userId, String deletedBy, String reason) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      await docRef.delete();

      // Log de suppression permanente pour audit
      await _logUserAction(
        action: 'PERMANENT_DELETE_USER_PROFILE',
        userId: userId,
        performedBy: deletedBy,
        metadata: {'reason': reason, 'deletionType': 'permanent'},
      );

      return const UserProfileSuccess(null);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la suppression permanente: ${error.toString()}',
          code: 'PERMANENT_DELETE_USER_PROFILE_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>>
      getPendingBeekeepers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('role.roleType',
              isEqualTo: UserRoleType.pendingBeekeeper.value)
          .where('role.isActive', isEqualTo: true)
          .get();

      final profiles = querySnapshot.docs
          .map((doc) => _mapDocumentToUserProfile(doc.id, doc.data()))
          .toList();

      return UserProfileSuccess(profiles);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la récupération des apiculteurs en attente: ${error.toString()}',
          code: 'GET_PENDING_BEEKEEPERS_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<UserProfileEntity>> validateBeekeeper(
      String userId, bool approved, String adminId,
      {String? comments}) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Profil utilisateur non trouvé',
            code: 'USER_PROFILE_NOT_FOUND',
          ),
        );
      }

      final currentData = docSnapshot.data()!;
      final currentProfile =
          _mapDocumentToUserProfile(docSnapshot.id, currentData);

      if (currentProfile.role.roleType != UserRoleType.pendingBeekeeper) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Cet utilisateur n\'est pas en attente de validation',
            code: 'NOT_PENDING_BEEKEEPER',
          ),
        );
      }

      // Mise à jour du rôle selon l'approbation
      final newRoleType =
          approved ? UserRoleType.beekeeper : UserRoleType.pendingBeekeeper;
      final updatedRole = currentProfile.role.copyWith(
        roleType: newRoleType,
        assignedAt: DateTime.now(),
        assignedBy: adminId,
      );

      final updatedProfile = currentProfile.copyWith(
        role: updatedRole,
        updatedAt: DateTime.now(),
        updatedBy: adminId,
      );

      await docRef.update({
        'role.roleType': newRoleType.value,
        'role.assignedAt': FieldValue.serverTimestamp(),
        'role.assignedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminId,
        'version': FieldValue.increment(1),
      });

      // Log de validation pour audit
      await _logUserAction(
        action: approved ? 'VALIDATE_BEEKEEPER' : 'REJECT_BEEKEEPER',
        userId: userId,
        performedBy: adminId,
        metadata: {
          'approved': approved,
          'comments': comments,
          'newRole': newRoleType.value,
        },
      );

      return UserProfileSuccess(updatedProfile);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la validation de l\'apiculteur: ${error.toString()}',
          code: 'VALIDATE_BEEKEEPER_ERROR',
          originalError: error,
        ),
      );
    }
  }

  Future<UserProfileResult<UserProfileEntity>> rejectBeekeeper(
      String userId, String rejectedBy, String rejectionReason) async {
    return validateBeekeeper(userId, false, rejectedBy,
        comments: rejectionReason);
  }

  @override
  Future<UserProfileResult<bool>> isEmailAlreadyUsed(String email,
      {String? excludeUserId}) async {
    try {
      if (email.isEmpty) {
        return UserProfileFailure(
          const ValidationError(
            message: 'L\'email ne peut pas être vide',
            code: 'EMPTY_EMAIL',
          ),
        );
      }

      Query query = _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email.toLowerCase().trim());

      if (excludeUserId != null && excludeUserId.isNotEmpty) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeUserId);
      }

      final querySnapshot = await query.get();
      final isUsed = querySnapshot.docs.isNotEmpty;

      return UserProfileSuccess(isUsed);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la vérification de l\'email: ${error.toString()}',
          code: 'CHECK_EMAIL_ERROR',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<UserProfileResult<List<UserProfileEntity>>> searchUsers(
      String searchTerm,
      {UserRoleType? roleFilter,
      bool? statusFilter}) async {
    try {
      if (searchTerm.isEmpty) {
        return UserProfileFailure(
          const ValidationError(
            message: 'Le terme de recherche ne peut pas être vide',
            code: 'EMPTY_SEARCH_TERM',
          ),
        );
      }

      Query query = _firestore.collection(_usersCollection);

      // Filtrage par rôle si spécifié
      if (roleFilter != null) {
        query = query.where('role.roleType', isEqualTo: roleFilter.value);
      }

      // Filtrage par statut si spécifié
      if (statusFilter != null) {
        query = query.where('role.isActive', isEqualTo: statusFilter);
      }

      final querySnapshot = await query.get();
      final allProfiles = querySnapshot.docs
          .map((doc) => _mapDocumentToUserProfile(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Filtrage local par terme de recherche
      final searchLower = searchTerm.toLowerCase();
      final filteredProfiles = allProfiles.where((profile) {
        return profile.firstName.toLowerCase().contains(searchLower) ||
            profile.lastName.toLowerCase().contains(searchLower) ||
            profile.email.toLowerCase().contains(searchLower) ||
            profile.fullName.toLowerCase().contains(searchLower);
      }).toList();

      return UserProfileSuccess(filteredProfiles);
    } catch (error) {
      return UserProfileFailure(
        ServiceError(
          message:
              'Erreur lors de la recherche d\'utilisateurs: ${error.toString()}',
          code: 'SEARCH_USERS_ERROR',
          originalError: error,
        ),
      );
    }
  }

  // === Méthodes privées de mapping ===

  UserProfileEntity _mapDocumentToUserProfile(
      String docId, Map<String, dynamic> data) {
    return UserProfileEntity(
      userId: docId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      city: data['city'],
      postalCode: data['postalCode'],
      country: data['country'],
      phoneNumber: data['phoneNumber'],
      role: _mapDocumentToUserRole(data['role'] is Map<String, dynamic>
          ? data['role'] as Map<String, dynamic>
          : {}),
      beekeeperDetails: data['beekeeperDetails'] is Map<String, dynamic>
          ? _mapDocumentToBeekeeperDetails(
              data['beekeeperDetails'] as Map<String, dynamic>)
          : null,
      isEmailVerified: data['isEmailVerified'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: data['deletedBy'],
      deletionReason: data['deletionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? 'SYSTEM',
      version: data['version'] ?? 1,
    );
  }

  Map<String, dynamic> _mapUserProfileToDocument(UserProfileEntity profile) {
    return {
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'email': profile.email.toLowerCase().trim(),
      'address': profile.address,
      'city': profile.city,
      'postalCode': profile.postalCode,
      'country': profile.country,
      'phoneNumber': profile.phoneNumber,
      'role': _mapUserRoleToDocument(profile.role),
      'beekeeperDetails': profile.beekeeperDetails != null
          ? _mapBeekeeperDetailsToDocument(profile.beekeeperDetails!)
          : null,
      'isEmailVerified': profile.isEmailVerified,
      'isDeleted': profile.isDeleted,
      'deletedAt': profile.deletedAt != null
          ? Timestamp.fromDate(profile.deletedAt!)
          : null,
      'deletedBy': profile.deletedBy,
      'deletionReason': profile.deletionReason,
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': Timestamp.fromDate(profile.updatedAt),
      'createdBy': profile.createdBy,
      'version': profile.version,
    };
  }

  UserRoleEntity _mapDocumentToUserRole(Map<String, dynamic> data) {
    return UserRoleEntity(
      roleType: UserRoleType.fromString(data['roleType'] ?? 'beekeeper'),
      assignedAt:
          (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedBy: data['assignedBy'],
      isActive: data['isActive'] ?? true,
      permissions: List<String>.from(data['permissions'] ?? []),
    );
  }

  Map<String, dynamic> _mapUserRoleToDocument(UserRoleEntity role) {
    return {
      'roleType': role.roleType.value,
      'assignedAt': Timestamp.fromDate(role.assignedAt),
      'assignedBy': role.assignedBy,
      'isActive': role.isActive,
      'permissions': role.permissions,
    };
  }

  BeekeeperDetailsEntity? _mapDocumentToBeekeeperDetails(
      Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    return BeekeeperDetailsEntity(
      beekeeperId: data['beekeeperId'],
      yearsOfExperience: data['yearsOfExperience'],
      beekeepingType:
          BeekeepingType.fromString(data['beekeepingType'] ?? 'hobbyist'),
      certifications: List<String>.from(data['certifications'] ?? []),
      totalHives: data['totalHives'] ?? 0,
      annualProduction: data['annualProduction']?.toDouble(),
      insuranceCompany: data['insuranceCompany'],
      insurancePolicyNumber: data['insurancePolicyNumber'],
      insuranceExpiryDate: data['insuranceExpiryDate'] != null
          ? (data['insuranceExpiryDate'] as Timestamp).toDate()
          : null,
      validationStatus: BeekeeperValidationStatus.fromString(
          data['validationStatus'] ?? 'pending'),
      validatedAt: data['validatedAt'] != null
          ? (data['validatedAt'] as Timestamp).toDate()
          : null,
      adminComments: data['adminComments'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> _mapBeekeeperDetailsToDocument(
      BeekeeperDetailsEntity details) {
    return {
      'beekeeperId': details.beekeeperId,
      'yearsOfExperience': details.yearsOfExperience,
      'beekeepingType': details.beekeepingType.value,
      'certifications': details.certifications,
      'totalHives': details.totalHives,
      'annualProduction': details.annualProduction,
      'insuranceCompany': details.insuranceCompany,
      'insurancePolicyNumber': details.insurancePolicyNumber,
      'insuranceExpiryDate': details.insuranceExpiryDate != null
          ? Timestamp.fromDate(details.insuranceExpiryDate!)
          : null,
      'validationStatus': details.validationStatus.value,
      'validatedAt': details.validatedAt != null
          ? Timestamp.fromDate(details.validatedAt!)
          : null,
      'adminComments': details.adminComments,
      'notes': details.notes,
    };
  }

  // === Validation ===

  void _validateUserProfile(UserProfileEntity profile) {
    if (profile.userId.isEmpty) {
      throw const ValidationError(
        message: 'L\'ID utilisateur ne peut pas être vide',
        code: 'EMPTY_USER_ID',
      );
    }

    if (profile.firstName.isEmpty) {
      throw const ValidationError(
        message: 'Le prénom ne peut pas être vide',
        code: 'EMPTY_FIRST_NAME',
      );
    }

    if (profile.lastName.isEmpty) {
      throw const ValidationError(
        message: 'Le nom ne peut pas être vide',
        code: 'EMPTY_LAST_NAME',
      );
    }

    if (profile.email.isEmpty) {
      throw const ValidationError(
        message: 'L\'email ne peut pas être vide',
        code: 'EMPTY_EMAIL',
      );
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(profile.email)) {
      throw const ValidationError(
        message: 'Format d\'email invalide',
        code: 'INVALID_EMAIL_FORMAT',
      );
    }
  }

  // === Logging pour audit ===

  Future<void> _logUserAction({
    required String action,
    required String userId,
    required String performedBy,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(_auditLogsCollection).add({
        'action': action,
        'userId': userId,
        'performedBy': performedBy,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
        'source': 'UserProfileRepository',
      });
    } catch (error) {
      // Log l'erreur mais ne fait pas échouer l'opération principale
      debugPrint('Erreur lors du log d\'audit: $error');
    }
  }
}
