import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case pour l'inscription avec email et mot de passe
class SignUpWithEmailPassword implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpWithEmailPassword(this.repository);

  @override
  Future<({UserEntity? result, Exception? error})> call(
      SignUpParams params) async {
    final response = await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );

    return (
      result: response.user,
      error: response.error as Exception?,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;

  const SignUpParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
