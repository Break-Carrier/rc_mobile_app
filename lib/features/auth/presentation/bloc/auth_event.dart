import 'package:equatable/equatable.dart';

/// Événements de base pour l'authentification
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Vérifier l'état d'authentification
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Connexion avec email et mot de passe
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Inscription avec email et mot de passe
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Déconnexion
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Réinitialisation du mot de passe
class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Vérification de l'email
class EmailVerificationRequested extends AuthEvent {
  const EmailVerificationRequested();
}

/// Actualiser les informations utilisateur
class UserReloadRequested extends AuthEvent {
  const UserReloadRequested();
}

/// Supprimer le compte
class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

/// Mettre à jour le profil
class UpdateProfileRequested extends AuthEvent {
  final String? displayName;
  final String? photoUrl;

  const UpdateProfileRequested({
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, photoUrl];
}
