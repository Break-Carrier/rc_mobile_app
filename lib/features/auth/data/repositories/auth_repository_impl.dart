import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/auth_failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implémentation du repository d'authentification
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }

  @override
  UserEntity? get currentUser {
    return remoteDataSource.currentUser;
  }

  @override
  Future<({UserEntity? user, AuthFailure? error})> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (user: user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _handleFirebaseAuthException(e));
    } catch (e) {
      return (user: null, error: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<({UserEntity? user, AuthFailure? error})> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (user: user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _handleFirebaseAuthException(e));
    } catch (e) {
      return (user: null, error: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<AuthFailure?> signOut() async {
    try {
      await remoteDataSource.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<AuthFailure?> resetPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.resetPassword(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<AuthFailure?> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<AuthFailure?> reloadUser() async {
    try {
      await remoteDataSource.reloadUser();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<AuthFailure?> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<AuthFailure?> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  /// Gère les exceptions Firebase Auth et les convertit en AuthFailure
  AuthFailure _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserNotFoundFailure(
          'Aucun utilisateur trouvé avec cette adresse email',
        );
      case 'wrong-password':
      case 'invalid-credential':
        return InvalidCredentialsFailure(
          'Email ou mot de passe incorrect',
        );
      case 'email-already-in-use':
        return EmailAlreadyInUseFailure(
          'Cette adresse email est déjà utilisée',
        );
      case 'weak-password':
        return WeakPasswordFailure(
          'Le mot de passe est trop faible',
        );
      case 'user-disabled':
        return UserDisabledFailure(
          'Ce compte utilisateur a été désactivé',
        );
      case 'too-many-requests':
        return TooManyRequestsFailure(
          'Trop de tentatives. Veuillez réessayer plus tard',
        );
      case 'network-request-failed':
        return NetworkFailure(
          'Erreur de connexion réseau',
        );
      case 'sign_in_canceled':
        return AuthenticationFailure(
          'Connexion annulée par l\'utilisateur',
        );
      default:
        return ServerFailure(
          e.message ?? 'Une erreur inconnue s\'est produite',
        );
    }
  }
}
