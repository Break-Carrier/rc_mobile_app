import 'package:get_it/get_it.dart';
import '../../../core/services/auth_service.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import '../domain/usecases/create_user_use_case.dart';

/// Configuration de l'injection de dépendances pour l'administration
class AdminInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Enregistre toutes les dépendances d'administration dans GetIt
  static void setupAdminDependencies() {
    // Use Cases
    if (!_getIt.isRegistered<CreateUserUseCase>()) {
      _getIt.registerLazySingleton<CreateUserUseCase>(
        () => CreateUserUseCase(
          _getIt<AuthService>(),
          _getIt<UserProfileRepository>(),
        ),
      );
    }
  }

  /// Récupère une instance du use case CreateUser
  static CreateUserUseCase getCreateUserUseCase() =>
      _getIt<CreateUserUseCase>();

  /// Supprime toutes les dépendances d'administration (pour les tests)
  static void resetAdminDependencies() {
    if (_getIt.isRegistered<CreateUserUseCase>()) {
      _getIt.unregister<CreateUserUseCase>();
    }
  }
}
