import '../../../../core/error/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Use case pour la déconnexion
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  /// Exécute la déconnexion
  Future<AuthFailure?> call() async {
    final error = await repository.signOut();
    return error;
  }
}
