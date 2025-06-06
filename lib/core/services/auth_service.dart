import 'package:firebase_auth/firebase_auth.dart';
import '../../features/user_profile/domain/entities/user_profile_entity.dart';
import '../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../error/app_error.dart';

/// Service d'authentification étendu avec gestion des profils et rôles
///
/// Ce service fait le pont entre Firebase Auth et notre système de profils
/// pour fournir une authentification complète avec gestion des rôles.
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final UserProfileRepository _userProfileRepository;

  const AuthService(
    this._firebaseAuth,
    this._userProfileRepository,
  );

  /// Utilisateur actuellement connecté (Firebase)
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Récupère le profil complet de l'utilisateur connecté
  ///
  /// Combine les données Firebase Auth avec le profil étendu
  Future<AuthResult<UserProfileEntity>> getCurrentUserProfile() async {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser == null) {
      return const AuthFailure(
        ValidationError(
          message: 'Aucun utilisateur connecté',
          code: 'NO_AUTHENTICATED_USER',
        ),
      );
    }

    final profileResult =
        await _userProfileRepository.getUserProfile(firebaseUser.uid);

    return switch (profileResult) {
      UserProfileSuccess(data: final profile) => AuthSuccess(profile),
      UserProfileFailure(error: final error) => AuthFailure(error),
    };
  }

  /// Vérifie si l'utilisateur connecté est administrateur
  Future<bool> isCurrentUserAdmin() async {
    final profileResult = await getCurrentUserProfile();
    return switch (profileResult) {
      AuthSuccess(data: final profile) => profile.isAdmin,
      AuthFailure() => false,
    };
  }

  /// Vérifie si l'utilisateur connecté est un apiculteur validé
  Future<bool> isCurrentUserValidatedBeekeeper() async {
    final profileResult = await getCurrentUserProfile();
    return switch (profileResult) {
      AuthSuccess(data: final profile) => profile.isValidatedBeekeeper,
      AuthFailure() => false,
    };
  }

  /// Vérifie si l'utilisateur connecté peut accéder aux fonctionnalités d'apiculture
  Future<bool> canAccessBeekeepingFeatures() async {
    final profileResult = await getCurrentUserProfile();
    return switch (profileResult) {
      AuthSuccess(data: final profile) => profile.canAccessBeekeepingFeatures,
      AuthFailure() => false,
    };
  }

  /// Vérifie si l'utilisateur connecté peut gérer d'autres utilisateurs
  Future<bool> canManageUsers() async {
    final profileResult = await getCurrentUserProfile();
    return switch (profileResult) {
      AuthSuccess(data: final profile) => profile.canManageUsers,
      AuthFailure() => false,
    };
  }

  /// Connexion avec email et mot de passe
  ///
  /// [email] - Adresse email
  /// [password] - Mot de passe
  ///
  /// Retourne le profil complet en cas de succès
  Future<AuthResult<UserProfileEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const AuthFailure(
          ValidationError(
            message: 'Échec de la connexion',
            code: 'SIGN_IN_FAILED',
          ),
        );
      }

      // Récupération du profil complet après connexion
      return await getCurrentUserProfile();
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleFirebaseAuthError(e));
    } catch (e) {
      return AuthFailure(ErrorHandler.handleError(e));
    }
  }

  /// Déconnexion
  Future<AuthResult<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const AuthSuccess(null);
    } catch (e) {
      return AuthFailure(ErrorHandler.handleError(e));
    }
  }

  /// Crée un nouvel utilisateur avec profil (pour les administrateurs)
  ///
  /// [email] - Adresse email
  /// [password] - Mot de passe temporaire
  /// [profile] - Profil utilisateur à créer
  ///
  /// Cette méthode est réservée aux administrateurs pour créer de nouveaux apiculteurs
  Future<AuthResult<UserProfileEntity>> createUserWithProfile(
    String email,
    String password,
    UserProfileEntity profile,
  ) async {
    try {
      // Vérification que l'utilisateur actuel est admin
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        return const AuthFailure(
          ValidationError(
            message:
                'Seuls les administrateurs peuvent créer de nouveaux utilisateurs',
            code: 'INSUFFICIENT_PERMISSIONS',
          ),
        );
      }

      // Création du compte Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const AuthFailure(
          ValidationError(
            message: 'Échec de la création du compte',
            code: 'ACCOUNT_CREATION_FAILED',
          ),
        );
      }

      // Création du profil utilisateur avec l'UID Firebase
      final profileWithId = profile.copyWith(userId: credential.user!.uid);
      final createResult =
          await _userProfileRepository.createUserProfile(profileWithId);

      return switch (createResult) {
        UserProfileSuccess(data: final createdProfile) =>
          AuthSuccess(createdProfile),
        UserProfileFailure(error: final error) => AuthFailure(error),
      };
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleFirebaseAuthError(e));
    } catch (e) {
      return AuthFailure(ErrorHandler.handleError(e));
    }
  }

  /// Gère les erreurs spécifiques à Firebase Auth
  AppError _handleFirebaseAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const ValidationError(
          message: 'Aucun utilisateur trouvé avec cette adresse email',
          code: 'USER_NOT_FOUND',
        ),
      'wrong-password' => const ValidationError(
          message: 'Mot de passe incorrect',
          code: 'WRONG_PASSWORD',
        ),
      'user-disabled' => const ValidationError(
          message: 'Ce compte utilisateur a été désactivé',
          code: 'USER_DISABLED',
        ),
      'too-many-requests' => const ValidationError(
          message: 'Trop de tentatives de connexion. Réessayez plus tard',
          code: 'TOO_MANY_REQUESTS',
        ),
      'email-already-in-use' => const ValidationError(
          message: 'Cette adresse email est déjà utilisée',
          code: 'EMAIL_ALREADY_IN_USE',
        ),
      'weak-password' => const ValidationError(
          message: 'Le mot de passe est trop faible',
          code: 'WEAK_PASSWORD',
        ),
      'invalid-email' => const ValidationError(
          message: 'Format d\'adresse email invalide',
          code: 'INVALID_EMAIL',
        ),
      _ => FirebaseError(
          message: 'Erreur d\'authentification: ${e.message}',
          code: e.code,
          originalError: e,
        ),
    };
  }
}

/// Résultat d'une opération d'authentification
sealed class AuthResult<T> {
  const AuthResult();
}

/// Succès d'une opération d'authentification
class AuthSuccess<T> extends AuthResult<T> {
  final T data;
  const AuthSuccess(this.data);
}

/// Échec d'une opération d'authentification
class AuthFailure<T> extends AuthResult<T> {
  final AppError error;
  const AuthFailure(this.error);
}
