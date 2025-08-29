import '../../features/user_profile/domain/entities/user_profile_entity.dart';
import '../../features/user_profile/domain/entities/user_role_entity.dart';
import '../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../services/auth_service.dart';

/// Service de bootstrap pour créer le premier administrateur
///
/// Responsabilité unique : Initialisation du premier compte admin
/// Utilisé une seule fois lors du premier déploiement
class AdminBootstrap {
  final AuthService _authService;
  final UserProfileRepository _userProfileRepository;

  AdminBootstrap(this._authService, this._userProfileRepository);

  /// Crée un profil admin pour l'utilisateur actuellement connecté
  ///
  /// À utiliser uniquement pour le bootstrap initial
  Future<BootstrapResult> createCurrentUserAsAdmin({
    required String firstName,
    required String lastName,
    String? address,
    String? phoneNumber,
  }) async {
    try {
      // Vérification qu'un utilisateur est connecté
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return BootstrapFailure('Aucun utilisateur connecté');
      }

      // Vérification que le profil n'existe pas déjà
      final existingProfileResult =
          await _userProfileRepository.getUserProfile(currentUser.uid);

      if (existingProfileResult is UserProfileSuccess) {
        return BootstrapFailure('Un profil existe déjà pour cet utilisateur');
      }

      // Création du profil admin
      final adminProfile = UserProfileEntity(
        userId: currentUser.uid,
        firstName: firstName,
        lastName: lastName,
        email: currentUser.email!,
        address: address ?? 'À compléter',
        phoneNumber: phoneNumber,
        role: UserRoleEntity(
          roleType: UserRoleType.admin,
          assignedAt: DateTime.now(),
          assignedBy: 'bootstrap', // Indicateur de création par bootstrap
          isActive: true,
        ),
        isEmailVerified: currentUser.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'bootstrap',
        version: 1,
      );

      // Sauvegarde du profil
      final result =
          await _userProfileRepository.createUserProfile(adminProfile);

      if (result is UserProfileSuccess) {
        return BootstrapSuccess((result as UserProfileSuccess).data);
      } else {
        final failure = result as UserProfileFailure;
        return BootstrapFailure('Erreur de création: ${failure.error.message}');
      }
    } catch (e) {
      return BootstrapFailure('Erreur inattendue: $e');
    }
  }

  /// Vérifie si un admin existe déjà dans le système
  Future<bool> hasExistingAdmin() async {
    try {
      final allBeekeepersResult =
          await _userProfileRepository.getAllBeekeepers(includeInactive: true);

      if (allBeekeepersResult is UserProfileSuccess) {
        return (allBeekeepersResult
                as UserProfileSuccess<List<UserProfileEntity>>)
            .data
            .any((profile) => profile.role.roleType == UserRoleType.admin);
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Résultat d'une opération de bootstrap
sealed class BootstrapResult {}

class BootstrapSuccess extends BootstrapResult {
  final UserProfileEntity adminProfile;
  BootstrapSuccess(this.adminProfile);
}

class BootstrapFailure extends BootstrapResult {
  final String message;
  BootstrapFailure(this.message);
}
