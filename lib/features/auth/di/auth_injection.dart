import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../../core/navigation/navigation_service.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_auth_state.dart';
import '../domain/usecases/sign_in_with_email_password.dart';
import '../domain/usecases/sign_up_with_email_password.dart';
import '../domain/usecases/sign_out.dart';
import '../domain/usecases/auth_navigation_usecases.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../presentation/bloc/auth_navigation_bloc.dart';

/// Configuration de l'injection de dépendances pour l'authentification
class AuthInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Enregistre toutes les dépendances d'authentification dans GetIt
  static void setupAuthDependencies() {
    // Firebase Auth
    if (!_getIt.isRegistered<FirebaseAuth>()) {
      _getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    }

    // Navigation Service
    if (!_getIt.isRegistered<NavigationService>()) {
      _getIt.registerLazySingleton<NavigationService>(
          () => NavigationServiceImpl());
    }

    // Data Source
    if (!_getIt.isRegistered<AuthRemoteDataSource>()) {
      _getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(firebaseAuth: _getIt<FirebaseAuth>()),
      );
    }

    // Repository
    if (!_getIt.isRegistered<AuthRepository>()) {
      _getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
            remoteDataSource: _getIt<AuthRemoteDataSource>()),
      );
    }

    // Use Cases - Authentication
    if (!_getIt.isRegistered<GetAuthState>()) {
      _getIt.registerLazySingleton<GetAuthState>(
        () => GetAuthState(_getIt<AuthRepository>()),
      );
    }

    if (!_getIt.isRegistered<SignInWithEmailPassword>()) {
      _getIt.registerLazySingleton<SignInWithEmailPassword>(
        () => SignInWithEmailPassword(_getIt<AuthRepository>()),
      );
    }

    if (!_getIt.isRegistered<SignUpWithEmailPassword>()) {
      _getIt.registerLazySingleton<SignUpWithEmailPassword>(
        () => SignUpWithEmailPassword(_getIt<AuthRepository>()),
      );
    }

    if (!_getIt.isRegistered<SignOut>()) {
      _getIt.registerLazySingleton<SignOut>(
        () => SignOut(_getIt<AuthRepository>()),
      );
    }

    // Use Cases - Navigation
    if (!_getIt.isRegistered<ShowLogoutDialog>()) {
      _getIt.registerLazySingleton<ShowLogoutDialog>(
        () => ShowLogoutDialog(_getIt<NavigationService>()),
      );
    }

    if (!_getIt.isRegistered<ShowAuthNotification>()) {
      _getIt.registerLazySingleton<ShowAuthNotification>(
        () => ShowAuthNotification(_getIt<NavigationService>()),
      );
    }

    // BLoCs
    if (!_getIt.isRegistered<AuthBloc>()) {
      _getIt.registerFactory<AuthBloc>(
        () => AuthBloc(
          getAuthState: _getIt<GetAuthState>(),
          signInWithEmailPassword: _getIt<SignInWithEmailPassword>(),
          signUpWithEmailPassword: _getIt<SignUpWithEmailPassword>(),
          signOut: _getIt<SignOut>(),
        ),
      );
    }

    if (!_getIt.isRegistered<AuthNavigationBloc>()) {
      _getIt.registerFactory<AuthNavigationBloc>(
        () => AuthNavigationBloc(
          showLogoutDialog: _getIt<ShowLogoutDialog>(),
          showAuthNotification: _getIt<ShowAuthNotification>(),
          authBloc: getAuthBloc(),
        ),
      );
    }
  }

  /// Récupère une instance du BLoC Auth
  static AuthBloc getAuthBloc() => _getIt<AuthBloc>();

  /// Récupère une instance du BLoC Auth Navigation
  static AuthNavigationBloc getAuthNavigationBloc() =>
      _getIt<AuthNavigationBloc>();

  /// Récupère le use case GetAuthState
  static GetAuthState getGetAuthStateUseCase() => _getIt<GetAuthState>();

  /// Supprime toutes les dépendances d'authentification (pour les tests)
  static void resetAuthDependencies() {
    if (_getIt.isRegistered<AuthNavigationBloc>()) {
      _getIt.unregister<AuthNavigationBloc>();
    }
    if (_getIt.isRegistered<AuthBloc>()) {
      _getIt.unregister<AuthBloc>();
    }
    if (_getIt.isRegistered<ShowAuthNotification>()) {
      _getIt.unregister<ShowAuthNotification>();
    }
    if (_getIt.isRegistered<ShowLogoutDialog>()) {
      _getIt.unregister<ShowLogoutDialog>();
    }
    if (_getIt.isRegistered<SignOut>()) {
      _getIt.unregister<SignOut>();
    }
    if (_getIt.isRegistered<SignUpWithEmailPassword>()) {
      _getIt.unregister<SignUpWithEmailPassword>();
    }
    if (_getIt.isRegistered<SignInWithEmailPassword>()) {
      _getIt.unregister<SignInWithEmailPassword>();
    }
    if (_getIt.isRegistered<GetAuthState>()) {
      _getIt.unregister<GetAuthState>();
    }
    if (_getIt.isRegistered<AuthRepository>()) {
      _getIt.unregister<AuthRepository>();
    }
    if (_getIt.isRegistered<AuthRemoteDataSource>()) {
      _getIt.unregister<AuthRemoteDataSource>();
    }
    if (_getIt.isRegistered<NavigationService>()) {
      _getIt.unregister<NavigationService>();
    }
    if (_getIt.isRegistered<FirebaseAuth>()) {
      _getIt.unregister<FirebaseAuth>();
    }
  }
}
