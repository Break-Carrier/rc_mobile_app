import 'package:get_it/get_it.dart';
import '../../../core/services/auth_service.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import '../domain/usecases/create_user_use_case.dart';
import '../domain/services/admin_role_service.dart';
import '../presentation/bloc/admin_role_bloc.dart';

/// Configuration de l'injection de dépendances pour l'administration
class AdminInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Enregistre toutes les dépendances d'administration dans GetIt
  static void setupAdminDependencies() {
    // Services
    if (!_getIt.isRegistered<AdminRoleService>()) {
      _getIt.registerLazySingleton<AdminRoleService>(
        () => AdminRoleService(_getIt<UserProfileRepository>()),
      );
    }

    // BLoCs
    if (!_getIt.isRegistered<AdminRoleBloc>()) {
      _getIt.registerFactory<AdminRoleBloc>(
        () => AdminRoleBloc(adminRoleService: _getIt<AdminRoleService>()),
      );
    }

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

  /// Récupère une instance du service AdminRole
  static AdminRoleService getAdminRoleService() => _getIt<AdminRoleService>();

  /// Récupère une instance du BLoC AdminRole
  static AdminRoleBloc getAdminRoleBloc() => _getIt<AdminRoleBloc>();

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
