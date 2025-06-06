import '../../../../core/services/auth_service.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/domain/entities/user_role_entity.dart';
import '../../../user_profile/domain/entities/beekeeper_details_entity.dart';
import '../../../../core/error/app_error.dart';

/// Use Case pour la création d'utilisateur par un administrateur
///
/// Principe de responsabilité unique : Orchestrer la création complète d'un utilisateur
/// (Firebase Auth + Profil métier)
class CreateUserUseCase {
  final AuthService _authService;
  final UserProfileRepository _userProfileRepository;

  const CreateUserUseCase(
    this._authService,
    this._userProfileRepository,
  );

  /// Crée un utilisateur complet (Auth + Profil)
  ///
  /// Fail Fast : Validation immédiate des entrées
  /// Single Responsibility : Une seule raison de changer
  Future<CreateUserResult> call(CreateUserParams params) async {
    _validateCreateUserParams(params);

    try {
      // 1. Création du compte Firebase Auth
      final authResult = await _createAuthAccount(params);
      if (authResult is AuthFailure) {
        return CreateUserFailure((authResult as AuthFailure).error);
      }

      final creationData = (authResult as AuthSuccess<UserCreationData>).data;

      // 2. Création du profil métier complet
      final profileResult = await _createUserProfile(creationData, params);
      if (profileResult is UserProfileFailure) {
        // Rollback : Supprimer le compte Firebase créé
        await _rollbackAuthAccount(creationData.userId);
        return CreateUserFailure((profileResult as UserProfileFailure).error);
      }

      // 3. Construction du résultat final
      final profile = (profileResult as UserProfileSuccess).data;
      final result = _buildCreateUserResult(creationData, profile);

      return CreateUserSuccess(result);
    } catch (e) {
      return CreateUserFailure(_handleUnexpectedError(e));
    }
  }

  // === Validation (Fail Fast) ===
  void _validateCreateUserParams(CreateUserParams params) {
    if (params.email.isEmpty) {
      throw const ValidationError(
        message: 'L\'email est requis',
        code: 'EMPTY_EMAIL',
      );
    }

    if (params.fullName.isEmpty) {
      throw const ValidationError(
        message: 'Le nom complet est requis',
        code: 'EMPTY_FULL_NAME',
      );
    }

    if (params.createdByAdminId.isEmpty) {
      throw const ValidationError(
        message: 'L\'ID de l\'administrateur créateur est requis',
        code: 'EMPTY_ADMIN_ID',
      );
    }
  }

  // === Opérations atomiques ===
  Future<AuthResult<UserCreationData>> _createAuthAccount(
    CreateUserParams params,
  ) async {
    return await _authService.createUserByAdmin(
      email: params.email,
      fullName: params.fullName,
      temporaryPassword: params.temporaryPassword,
    );
  }

  Future<UserProfileResult<UserProfileEntity>> _createUserProfile(
    UserCreationData creationData,
    CreateUserParams params,
  ) async {
    final profile = _buildUserProfileEntity(creationData, params);
    return await _userProfileRepository.createUserProfile(profile);
  }

  // === Construction d'objets (Factory Methods) ===
  UserProfileEntity _buildUserProfileEntity(
    UserCreationData creationData,
    CreateUserParams params,
  ) {
    final nameParts = _splitFullName(creationData.fullName);

    return UserProfileEntity(
      userId: creationData.userId,
      firstName: nameParts.firstName,
      lastName: nameParts.lastName,
      email: creationData.email,
      address: '', // À compléter par l'utilisateur
      phoneNumber: params.phoneNumber ?? '',
      role: _createUserRole(params),
      beekeeperDetails: params.beekeeperDetails,
      createdAt: creationData.createdAt,
      updatedAt: creationData.createdAt,
      createdBy: params.createdByAdminId,
      version: 1,
    );
  }

  UserRoleEntity _createUserRole(CreateUserParams params) {
    return UserRoleEntity(
      roleType: params.roleType,
      assignedAt: DateTime.now(),
      assignedBy: params.createdByAdminId,
    );
  }

  CreateUserResultData _buildCreateUserResult(
    UserCreationData creationData,
    UserProfileEntity profile,
  ) {
    return CreateUserResultData(
      userId: profile.userId,
      email: profile.email,
      fullName: profile.fullName,
      temporaryPassword: creationData.temporaryPassword,
      role: profile.role,
      createdAt: creationData.createdAt,
    );
  }

  // === Utilitaires (Fonctions pures) ===
  NameParts _splitFullName(String fullName) {
    final parts = fullName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : fullName;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return NameParts(firstName: firstName, lastName: lastName);
  }

  // === Gestion des erreurs ===
  AppError _handleUnexpectedError(dynamic error) {
    return ServiceError(
      message: 'Erreur lors de la création d\'utilisateur: ${error.toString()}',
      code: 'USER_CREATION_UNEXPECTED_ERROR',
      originalError: error,
    );
  }

  // === Rollback (Compensation) ===
  Future<void> _rollbackAuthAccount(String userId) async {
    try {
      // TODO: Implémenter la suppression du compte Firebase
      // Nécessite Firebase Admin SDK ou Cloud Functions
      print('ROLLBACK : Suppression du compte Firebase $userId nécessaire');
    } catch (e) {
      // Log de l'erreur mais ne pas faire échouer le processus principal
      print('Erreur lors du rollback du compte $userId: $e');
    }
  }
}

// === Value Objects ===

/// Paramètres d'entrée pour la création d'utilisateur
class CreateUserParams {
  final String email;
  final String fullName;
  final UserRoleType roleType;
  final String createdByAdminId;
  final String? phoneNumber;
  final String? temporaryPassword;
  final BeekeeperDetailsEntity? beekeeperDetails;

  const CreateUserParams({
    required this.email,
    required this.fullName,
    required this.roleType,
    required this.createdByAdminId,
    this.phoneNumber,
    this.temporaryPassword,
    this.beekeeperDetails,
  });
}

/// Données de résultat de création d'utilisateur
class CreateUserResultData {
  final String userId;
  final String email;
  final String fullName;
  final String temporaryPassword;
  final UserRoleEntity role;
  final DateTime createdAt;

  const CreateUserResultData({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.temporaryPassword,
    required this.role,
    required this.createdAt,
  });
}

/// Séparation de nom (Value Object)
class NameParts {
  final String firstName;
  final String lastName;

  const NameParts({
    required this.firstName,
    required this.lastName,
  });
}

// === Result Types ===

sealed class CreateUserResult {}

class CreateUserSuccess extends CreateUserResult {
  final CreateUserResultData data;
  CreateUserSuccess(this.data);
}

class CreateUserFailure extends CreateUserResult {
  final AppError error;
  CreateUserFailure(this.error);
}
