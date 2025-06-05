import 'package:equatable/equatable.dart';
import '../../../../core/error/auth_failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case pour l'inscription avec email et mot de passe
class SignUpWithEmailPassword {
  final AuthRepository repository;

  SignUpWithEmailPassword(this.repository);

  /// Exécute l'inscription avec email et mot de passe
  Future<({UserEntity? result, AuthFailure? error})> call(
      SignUpParams params) async {
    final response = await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );

    return (
      result: response.user,
      error: response.error,
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
