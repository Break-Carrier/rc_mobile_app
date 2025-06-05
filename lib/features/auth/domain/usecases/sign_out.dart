import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case pour la déconnexion
class SignOut implements VoidUseCase0 {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Exception?> call() async {
    final error = await repository.signOut();
    return error as Exception?;
  }
}
