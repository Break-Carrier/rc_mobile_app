import 'package:equatable/equatable.dart';
import '../../../../core/error/auth_failures.dart';
import '../../domain/entities/user_entity.dart';

/// États de base pour l'authentification
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Chargement en cours
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Utilisateur authentifié
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// Utilisateur non authentifié
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Erreur d'authentification
class AuthError extends AuthState {
  final AuthFailure failure;

  const AuthError({required this.failure});

  @override
  List<Object> get props => [failure];
}

/// Email de réinitialisation envoyé
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Email de vérification envoyé
class AuthEmailVerificationSent extends AuthState {
  const AuthEmailVerificationSent();
}

/// Profil mis à jour avec succès
class AuthProfileUpdated extends AuthState {
  final UserEntity user;

  const AuthProfileUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

/// Compte supprimé avec succès
class AuthAccountDeleted extends AuthState {
  const AuthAccountDeleted();
}
