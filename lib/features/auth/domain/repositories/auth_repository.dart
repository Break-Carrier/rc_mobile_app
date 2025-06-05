import '../../../../core/error/auth_failures.dart';
import '../entities/user_entity.dart';

/// Interface du repository d'authentification
abstract class AuthRepository {
  /// Stream de l'état d'authentification
  Stream<UserEntity?> get authStateChanges;

  /// Utilisateur actuellement connecté
  UserEntity? get currentUser;

  /// Connexion avec email et mot de passe
  Future<({UserEntity? user, AuthFailure? error})> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Inscription avec email et mot de passe
  Future<({UserEntity? user, AuthFailure? error})> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Déconnexion
  Future<AuthFailure?> signOut();

  /// Réinitialisation du mot de passe
  Future<AuthFailure?> resetPassword({
    required String email,
  });

  /// Vérification de l'email
  Future<AuthFailure?> sendEmailVerification();

  /// Actualiser les informations utilisateur
  Future<AuthFailure?> reloadUser();

  /// Supprimer le compte utilisateur
  Future<AuthFailure?> deleteAccount();

  /// Mettre à jour le profil utilisateur
  Future<AuthFailure?> updateProfile({
    String? displayName,
    String? photoUrl,
  });
}
