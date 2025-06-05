import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case pour obtenir l'état d'authentification
class GetAuthState {
  final AuthRepository repository;

  GetAuthState(this.repository);

  /// Stream de l'état d'authentification
  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }

  /// Utilisateur actuellement connecté
  UserEntity? getCurrentUser() {
    return repository.currentUser;
  }
}
