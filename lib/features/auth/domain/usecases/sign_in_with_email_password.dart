import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case pour la connexion avec email et mot de passe
class SignInWithEmailPassword implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInWithEmailPassword(this.repository);

  @override
  Future<({UserEntity? result, Exception? error})> call(
      SignInParams params) async {
    final response = await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );

    return (
      result: response.user,
      error: response.error as Exception?,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
