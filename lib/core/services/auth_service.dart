import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../error/app_error.dart';

/// Service d'authentification suivant les principes Clean Code
///
/// Responsabilité unique : Gestion de l'authentification Firebase Auth
/// Chaque méthode fait une seule chose et la fait bien
class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // === État d'authentification (Getters simples) ===
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // === Connexion utilisateur existant ===
  Future<AuthResult<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _validateEmailAndPassword(email, password);

    try {
      final credential = await _attemptSignIn(email, password);
      return _handleSignInResult(credential);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseAuthError(e));
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  // === Création d'utilisateur par admin ===
  Future<AuthResult<UserCreationData>> createUserByAdmin({
    required String email,
    required String fullName,
    String? temporaryPassword,
  }) async {
    _validateUserCreationInputs(email, fullName);

    try {
      final password = _generateOrUsePassword(temporaryPassword);
      final credential = await _createFirebaseUser(email, password);
      await _updateUserDisplayName(credential.user!, fullName);

      final creationData = _buildUserCreationData(credential.user!, password);
      _logUserCreationInDevMode(creationData);

      return AuthSuccess(creationData);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseAuthError(e));
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  // === Réinitialisation de mot de passe ===
  Future<AuthResult<void>> resetPassword({
    required String email,
  }) async {
    _validateEmail(email);

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthSuccess(null);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseAuthError(e));
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  // === Changement de mot de passe ===
  Future<AuthResult<void>> updatePassword({
    required String newPassword,
  }) async {
    _validatePassword(newPassword);

    try {
      final user = _getCurrentUserOrThrow();
      await user.updatePassword(newPassword);
      return AuthSuccess(null);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseAuthError(e));
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  // === Déconnexion ===
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // === Validation d'entrée (Fail Fast) ===
  void _validateEmailAndPassword(String email, String password) {
    _validateEmail(email);
    _validatePassword(password);
  }

  void _validateUserCreationInputs(String email, String fullName) {
    _validateEmail(email);
    _validateFullName(fullName);
  }

  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw const ValidationError(
        message: 'L\'email est requis',
        code: 'EMPTY_EMAIL',
      );
    }

    if (!_isValidEmailFormat(email)) {
      throw const ValidationError(
        message: 'Format d\'email invalide',
        code: 'INVALID_EMAIL_FORMAT',
      );
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw const ValidationError(
        message: 'Le mot de passe est requis',
        code: 'EMPTY_PASSWORD',
      );
    }

    if (password.length < 6) {
      throw const ValidationError(
        message: 'Le mot de passe doit contenir au moins 6 caractères',
        code: 'WEAK_PASSWORD',
      );
    }
  }

  void _validateFullName(String fullName) {
    if (fullName.isEmpty) {
      throw const ValidationError(
        message: 'Le nom complet est requis',
        code: 'EMPTY_FULL_NAME',
      );
    }

    if (fullName.length < 2) {
      throw const ValidationError(
        message: 'Le nom doit contenir au moins 2 caractères',
        code: 'INVALID_FULL_NAME',
      );
    }
  }

  // === Opérations Firebase (Fonctions focalisées) ===
  Future<UserCredential> _attemptSignIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> _createFirebaseUser(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> _updateUserDisplayName(User user, String displayName) async {
    await user.updateDisplayName(displayName);
  }

  // === Gestion des résultats ===
  AuthResult<User> _handleSignInResult(UserCredential credential) {
    if (credential.user == null) {
      return AuthFailure(
        const AuthenticationError(
          message: 'Échec de l\'authentification',
          code: 'SIGN_IN_FAILED',
        ),
      );
    }

    return AuthSuccess(credential.user!);
  }

  AuthResult<T> _handleUnexpectedError<T>(dynamic error) {
    return AuthFailure(
      AuthenticationError(
        message: 'Erreur inattendue: ${error.toString()}',
        code: 'UNEXPECTED_ERROR',
      ),
    );
  }

  // === Utilitaires (Fonctions pures) ===
  String _generateOrUsePassword(String? providedPassword) {
    return providedPassword?.isNotEmpty == true
        ? providedPassword!
        : _generateSecureTemporaryPassword();
  }

  String _generateSecureTemporaryPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%';
    final random = DateTime.now().millisecondsSinceEpoch;

    return List.generate(12, (index) {
      return chars[(random + index) % chars.length];
    }).join();
  }

  bool _isValidEmailFormat(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isInDevelopmentMode() {
    return currentUser?.email?.contains('test') ?? false;
  }

  User _getCurrentUserOrThrow() {
    final user = currentUser;
    if (user == null) {
      throw const AuthenticationError(
        message: 'Aucun utilisateur connecté',
        code: 'NOT_AUTHENTICATED',
      );
    }
    return user;
  }

  // === Construction d'objets ===
  UserCreationData _buildUserCreationData(User user, String temporaryPassword) {
    return UserCreationData(
      user: user,
      temporaryPassword: temporaryPassword,
      createdAt: DateTime.now(),
    );
  }

  // === Logging (Side effect isolé) ===
  void _logUserCreationInDevMode(UserCreationData data) {
    if (!_isInDevelopmentMode()) return;

    // TODO: Remplacer par un système de logging approprié
    // print() évité en production pour respecter les bonnes pratiques
    debugPrint('''
📧 COMPTE CRÉÉ EN MODE DÉVELOPPEMENT :
-----------------------------------
Email: ${data.user.email}
Mot de passe temporaire: ${data.temporaryPassword}
Nom: ${data.user.displayName}
UID: ${data.user.uid}
-----------------------------------
    ''');
  }

  // === Mappage d'erreurs (Fonction pure) ===
  AppError _mapFirebaseAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const AuthenticationError(
          message: 'Aucun utilisateur trouvé avec cet email',
          code: 'USER_NOT_FOUND',
        ),
      'wrong-password' => const AuthenticationError(
          message: 'Mot de passe incorrect',
          code: 'WRONG_PASSWORD',
        ),
      'email-already-in-use' => const ValidationError(
          message: 'Cet email est déjà utilisé',
          code: 'EMAIL_ALREADY_IN_USE',
        ),
      'weak-password' => const ValidationError(
          message: 'Le mot de passe est trop faible',
          code: 'WEAK_PASSWORD',
        ),
      'invalid-email' => const ValidationError(
          message: 'Format d\'email invalide',
          code: 'INVALID_EMAIL',
        ),
      'too-many-requests' => const NetworkError(
          message: 'Trop de tentatives. Réessayez plus tard',
          code: 'TOO_MANY_REQUESTS',
        ),
      _ => AuthenticationError(
          message: e.message ?? 'Erreur d\'authentification',
          code: e.code,
        ),
    };
  }
}

// === Value Objects (Clean Architecture) ===

/// Données de création d'utilisateur (Value Object)
class UserCreationData {
  final User user;
  final String temporaryPassword;
  final DateTime createdAt;

  const UserCreationData({
    required this.user,
    required this.temporaryPassword,
    required this.createdAt,
  });

  String get email => user.email ?? '';
  String get fullName => user.displayName ?? '';
  String get userId => user.uid;
}

// === Result Types (Type Safety) ===

sealed class AuthResult<T> {}

class AuthSuccess<T> extends AuthResult<T> {
  final T data;
  AuthSuccess(this.data);
}

class AuthFailure<T> extends AuthResult<T> {
  final AppError error;
  AuthFailure(this.error);
}
