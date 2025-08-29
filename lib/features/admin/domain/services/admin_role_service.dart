import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/app_error.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../user_profile/domain/entities/user_role_entity.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';

/// Service pour la gestion des rôles administrateur
///
/// Responsabilité unique : Vérification et attribution des rôles admin
/// Intégré dans l'architecture Clean existante
class AdminRoleService {
  final UserProfileRepository _userProfileRepository;
  final FirebaseFirestore _firestore;

  AdminRoleService(
    this._userProfileRepository, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Vérifie si un utilisateur est administrateur
  ///
  /// [userId] - UID Firebase de l'utilisateur
  /// Retourne true si l'utilisateur est admin, false sinon
  Future<AdminRoleResult<bool>> isUserAdmin(String userId) async {
    try {
      if (userId.isEmpty) {
        return AdminRoleFailure(
          const ValidationError(
            message: 'L\'ID utilisateur ne peut pas être vide',
            code: 'EMPTY_USER_ID',
          ),
        );
      }

      // Vérification dans le profil utilisateur
      final profileResult = await _userProfileRepository.getUserProfile(userId);

      if (profileResult is UserProfileFailure) {
        return AdminRoleFailure((profileResult as UserProfileFailure).error);
      }

      final profile = (profileResult as UserProfileSuccess).data;
      return AdminRoleSuccess(profile.isAdmin);
    } catch (error) {
      return AdminRoleFailure(
        ServiceError(
          message:
              'Erreur lors de la vérification du rôle admin: ${error.toString()}',
          code: 'ADMIN_CHECK_ERROR',
          originalError: error,
        ),
      );
    }
  }

  /// Promeut un utilisateur au rôle administrateur
  ///
  /// [targetUserId] - UID de l'utilisateur à promouvoir
  /// [adminUserId] - UID de l'administrateur effectuant l'action
  /// Seuls les administrateurs existants peuvent promouvoir d'autres utilisateurs
  Future<AdminRoleResult<void>> promoteToAdmin({
    required String targetUserId,
    required String adminUserId,
    String? reason,
  }) async {
    try {
      // Validation des paramètres
      final validationError =
          _validatePromotionParams(targetUserId, adminUserId);
      if (validationError != null) {
        return AdminRoleFailure(validationError);
      }

      // Vérification que l'utilisateur effectuant l'action est admin
      final adminCheckResult = await isUserAdmin(adminUserId);
      if (adminCheckResult is AdminRoleFailure) {
        return AdminRoleFailure((adminCheckResult as AdminRoleFailure).error);
      }

      final isCurrentUserAdmin = (adminCheckResult as AdminRoleSuccess).data;
      if (!isCurrentUserAdmin) {
        return AdminRoleFailure(
          const ValidationError(
            message:
                'Seuls les administrateurs peuvent promouvoir d\'autres utilisateurs',
            code: 'INSUFFICIENT_PERMISSIONS',
          ),
        );
      }

      // Récupération du profil cible
      final targetProfileResult =
          await _userProfileRepository.getUserProfile(targetUserId);
      if (targetProfileResult is UserProfileFailure) {
        return AdminRoleFailure(
            (targetProfileResult as UserProfileFailure).error);
      }

      final targetProfile = (targetProfileResult as UserProfileSuccess).data;

      // Vérification si l'utilisateur n'est pas déjà admin
      if (targetProfile.isAdmin) {
        return AdminRoleFailure(
          const ValidationError(
            message: 'Cet utilisateur est déjà administrateur',
            code: 'ALREADY_ADMIN',
          ),
        );
      }

      // Création du nouveau rôle admin
      final adminRole = UserRoleEntity(
        roleType: UserRoleType.admin,
        assignedAt: DateTime.now(),
        assignedBy: adminUserId,
        isActive: true,
      );

      // Mise à jour du profil avec le nouveau rôle
      final updateResult = await _userProfileRepository.updateUserRole(
        targetUserId,
        adminRole,
        adminUserId,
      );

      if (updateResult is UserProfileFailure) {
        return AdminRoleFailure((updateResult as UserProfileFailure).error);
      }

      // Log de l'action pour audit
      await _logAdminAction(
        action: 'PROMOTE_TO_ADMIN',
        targetUserId: targetUserId,
        performedBy: adminUserId,
        reason: reason,
      );

      return AdminRoleSuccess(null);
    } catch (error) {
      return AdminRoleFailure(
        ServiceError(
          message:
              'Erreur lors de la promotion en administrateur: ${error.toString()}',
          code: 'ADMIN_PROMOTION_ERROR',
          originalError: error,
        ),
      );
    }
  }

  /// Retire le rôle administrateur d'un utilisateur
  ///
  /// [targetUserId] - UID de l'utilisateur à rétrograder
  /// [adminUserId] - UID de l'administrateur effectuant l'action
  Future<AdminRoleResult<void>> demoteFromAdmin({
    required String targetUserId,
    required String adminUserId,
    String? reason,
  }) async {
    try {
      // Validation des paramètres
      final validationError =
          _validatePromotionParams(targetUserId, adminUserId);
      if (validationError != null) {
        return AdminRoleFailure(validationError);
      }

      // Empêcher l'auto-rétrogradation
      if (targetUserId == adminUserId) {
        return AdminRoleFailure(
          const ValidationError(
            message: 'Vous ne pouvez pas retirer vos propres privilèges admin',
            code: 'CANNOT_DEMOTE_SELF',
          ),
        );
      }

      // Vérification que l'utilisateur effectuant l'action est admin
      final adminCheckResult = await isUserAdmin(adminUserId);
      if (adminCheckResult is AdminRoleFailure) {
        return AdminRoleFailure((adminCheckResult as AdminRoleFailure).error);
      }

      final isCurrentUserAdmin = (adminCheckResult as AdminRoleSuccess).data;
      if (!isCurrentUserAdmin) {
        return AdminRoleFailure(
          const ValidationError(
            message:
                'Seuls les administrateurs peuvent rétrograder d\'autres administrateurs',
            code: 'INSUFFICIENT_PERMISSIONS',
          ),
        );
      }

      // Récupération du profil cible
      final targetProfileResult =
          await _userProfileRepository.getUserProfile(targetUserId);
      if (targetProfileResult is UserProfileFailure) {
        return AdminRoleFailure(
            (targetProfileResult as UserProfileFailure).error);
      }

      final targetProfile = (targetProfileResult as UserProfileSuccess).data;

      // Vérification si l'utilisateur est admin
      if (!targetProfile.isAdmin) {
        return AdminRoleFailure(
          const ValidationError(
            message: 'Cet utilisateur n\'est pas administrateur',
            code: 'NOT_ADMIN',
          ),
        );
      }

      // Création du nouveau rôle apiculteur
      final beekeeperRole = UserRoleEntity(
        roleType: UserRoleType.beekeeper,
        assignedAt: DateTime.now(),
        assignedBy: adminUserId,
        isActive: true,
      );

      // Mise à jour du profil avec le nouveau rôle
      final updateResult = await _userProfileRepository.updateUserRole(
        targetUserId,
        beekeeperRole,
        adminUserId,
      );

      if (updateResult is UserProfileFailure) {
        return AdminRoleFailure((updateResult as UserProfileFailure).error);
      }

      // Log de l'action pour audit
      await _logAdminAction(
        action: 'DEMOTE_FROM_ADMIN',
        targetUserId: targetUserId,
        performedBy: adminUserId,
        reason: reason,
      );

      return AdminRoleSuccess(null);
    } catch (error) {
      return AdminRoleFailure(
        ServiceError(
          message: 'Erreur lors de la rétrogradation: ${error.toString()}',
          code: 'ADMIN_DEMOTION_ERROR',
          originalError: error,
        ),
      );
    }
  }

  /// Liste tous les administrateurs
  ///
  /// [requestedBy] - UID de l'utilisateur demandant la liste
  Future<AdminRoleResult<List<AdminInfo>>> getAllAdmins({
    required String requestedBy,
  }) async {
    try {
      // Vérification des permissions
      final adminCheckResult = await isUserAdmin(requestedBy);
      if (adminCheckResult is AdminRoleFailure) {
        return AdminRoleFailure((adminCheckResult as AdminRoleFailure).error);
      }

      final isAdmin = (adminCheckResult as AdminRoleSuccess).data;
      if (!isAdmin) {
        return AdminRoleFailure(
          const ValidationError(
            message:
                'Seuls les administrateurs peuvent voir la liste des admins',
            code: 'INSUFFICIENT_PERMISSIONS',
          ),
        );
      }

      // Récupération de tous les apiculteurs
      final allUsersResult = await _userProfileRepository.getAllBeekeepers();
      if (allUsersResult is UserProfileFailure) {
        return AdminRoleFailure((allUsersResult as UserProfileFailure).error);
      }

      final allUsers = (allUsersResult as UserProfileSuccess).data;

      // Filtrage pour ne garder que les admins
      final admins = allUsers
          .where((user) => user.isAdmin)
          .map((user) => AdminInfo(
                userId: user.userId,
                email: user.email,
                fullName: user.fullName,
                assignedAt: user.role.assignedAt,
                assignedBy: user.role.assignedBy,
              ))
          .toList();

      return AdminRoleSuccess(admins);
    } catch (error) {
      return AdminRoleFailure(
        ServiceError(
          message:
              'Erreur lors de la récupération des administrateurs: ${error.toString()}',
          code: 'ADMIN_LIST_ERROR',
          originalError: error,
        ),
      );
    }
  }

  /// Bootstrap : Crée le premier administrateur à partir d'un utilisateur connecté
  ///
  /// À utiliser uniquement lors de l'initialisation du système
  Future<AdminRoleResult<void>> bootstrapFirstAdmin(UserEntity user) async {
    try {
      // Vérification qu'aucun admin n'existe déjà
      final existingAdminsResult = await _checkIfAnyAdminExists();
      if (existingAdminsResult is AdminRoleFailure) {
        return AdminRoleFailure(
            (existingAdminsResult as AdminRoleFailure).error);
      }

      final hasExistingAdmins = (existingAdminsResult as AdminRoleSuccess).data;
      if (hasExistingAdmins) {
        return AdminRoleFailure(
          const ValidationError(
            message: 'Des administrateurs existent déjà dans le système',
            code: 'ADMINS_ALREADY_EXIST',
          ),
        );
      }

      // Récupération ou création du profil utilisateur
      final profileResult =
          await _userProfileRepository.getUserProfile(user.id);

      if (profileResult is UserProfileFailure) {
        // Si le profil n'existe pas, on le crée
        await _createAdminProfile(user);
      } else {
        // Si le profil existe, on met à jour le rôle
        final adminRole = UserRoleEntity(
          roleType: UserRoleType.admin,
          assignedAt: DateTime.now(),
          assignedBy: 'SYSTEM_BOOTSTRAP',
          isActive: true,
        );

        final updateResult = await _userProfileRepository.updateUserRole(
          user.id,
          adminRole,
          'SYSTEM_BOOTSTRAP',
        );

        if (updateResult is UserProfileFailure) {
          return AdminRoleFailure((updateResult as UserProfileFailure).error);
        }
      }

      // Log de l'action
      await _logAdminAction(
        action: 'BOOTSTRAP_FIRST_ADMIN',
        targetUserId: user.id,
        performedBy: 'SYSTEM_BOOTSTRAP',
        reason: 'Initial system setup',
      );

      return AdminRoleSuccess(null);
    } catch (error) {
      return AdminRoleFailure(
        ServiceError(
          message: 'Erreur lors du bootstrap admin: ${error.toString()}',
          code: 'ADMIN_BOOTSTRAP_ERROR',
          originalError: error,
        ),
      );
    }
  }

  // === Méthodes privées ===

  ValidationError? _validatePromotionParams(
      String targetUserId, String adminUserId) {
    if (targetUserId.isEmpty) {
      return const ValidationError(
        message: 'L\'ID de l\'utilisateur cible ne peut pas être vide',
        code: 'EMPTY_TARGET_USER_ID',
      );
    }

    if (adminUserId.isEmpty) {
      return const ValidationError(
        message: 'L\'ID de l\'administrateur ne peut pas être vide',
        code: 'EMPTY_ADMIN_USER_ID',
      );
    }

    return null;
  }

  Future<AdminRoleResult<bool>> _checkIfAnyAdminExists() async {
    try {
      final allUsersResult = await _userProfileRepository.getAllBeekeepers();
      if (allUsersResult is UserProfileFailure) {
        return AdminRoleFailure((allUsersResult as UserProfileFailure).error);
      }

      final allUsers = (allUsersResult as UserProfileSuccess).data;
      final hasAdmins = allUsers.any((user) => user.isAdmin);

      return AdminRoleSuccess(hasAdmins);
    } catch (error) {
      return AdminRoleFailure(
        ServiceError(
          message:
              'Erreur lors de la vérification des admins existants: ${error.toString()}',
          code: 'ADMIN_CHECK_ERROR',
          originalError: error,
        ),
      );
    }
  }

  Future<void> _createAdminProfile(UserEntity user) async {
    // Création d'un profil admin de base
    final nameParts =
        user.displayName?.split(' ') ?? [user.email.split('@').first];
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'Admin';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final adminProfile = UserProfileEntity(
      userId: user.id,
      firstName: firstName,
      lastName: lastName,
      email: user.email,
      address: 'À renseigner',
      role: UserRoleEntity(
        roleType: UserRoleType.admin,
        assignedAt: DateTime.now(),
        assignedBy: 'SYSTEM_BOOTSTRAP',
        isActive: true,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'SYSTEM_BOOTSTRAP',
      version: 1,
    );

    await _userProfileRepository.createUserProfile(adminProfile);
  }

  Future<void> _logAdminAction({
    required String action,
    required String targetUserId,
    required String performedBy,
    String? reason,
  }) async {
    try {
      await _firestore.collection('admin_actions').add({
        'action': action,
        'targetUserId': targetUserId,
        'performedBy': performedBy,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': {
          'version': '1.0.0',
          'source': 'AdminRoleService',
        },
      });
    } catch (error) {
      // Log l'erreur mais ne fait pas échouer l'opération principale
      // TODO: Implémenter un logger approprié
      debugPrint('Erreur lors du log admin: $error');
    }
  }
}

// === Modèles de résultat ===

sealed class AdminRoleResult<T> {
  const AdminRoleResult();
}

class AdminRoleSuccess<T> extends AdminRoleResult<T> {
  final T data;
  const AdminRoleSuccess(this.data);
}

class AdminRoleFailure<T> extends AdminRoleResult<T> {
  final AppError error;
  const AdminRoleFailure(this.error);
}

// === Modèles de données ===

class AdminInfo {
  final String userId;
  final String email;
  final String fullName;
  final DateTime assignedAt;
  final String? assignedBy;

  const AdminInfo({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.assignedAt,
    this.assignedBy,
  });
}
