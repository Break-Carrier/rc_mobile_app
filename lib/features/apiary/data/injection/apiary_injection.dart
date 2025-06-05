import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/domain/usecases/get_auth_state.dart';
import '../../domain/repositories/apiary_repository.dart';
import '../../domain/usecases/create_apiary.dart';
import '../../domain/usecases/delete_apiary.dart';
import '../../domain/usecases/get_current_user_id.dart';
import '../../domain/usecases/get_user_apiaries.dart';
import '../../domain/usecases/update_apiary.dart';
import '../../presentation/bloc/apiary_bloc.dart';
import '../repositories/firebase_apiary_repository.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';

/// Configuration de l'injection de dépendances pour le module Ruchers
class ApiaryInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Enregistre toutes les dépendances du module Ruchers
  static void setupApiaryDependencies() {
    // Repository
    _getIt.registerLazySingleton<ApiaryRepository>(
      () => FirebaseApiaryRepository(
        _getIt<FirebaseDatabase>(),
        _getIt<Logger>(),
      ),
    );

    // Use Cases utilitaires
    _getIt.registerLazySingleton<GetCurrentUserId>(
      () {
        try {
          return GetCurrentUserId(_getIt<GetAuthState>());
        } catch (e) {
          // Fallback : créer un GetAuthState temporaire si l'injection auth a échoué
          final authState = GetAuthState(
            AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(
                firebaseAuth: FirebaseAuth.instance,
              ),
            ),
          );
          // L'enregistrer pour éviter de le recréer
          if (!_getIt.isRegistered<GetAuthState>()) {
            _getIt.registerLazySingleton<GetAuthState>(() => authState);
          }
          return GetCurrentUserId(authState);
        }
      },
    );

    // Use Cases CRUD
    _getIt.registerLazySingleton<CreateApiary>(
      () => CreateApiary(
        _getIt<ApiaryRepository>(),
        _getIt<GetCurrentUserId>(),
      ),
    );

    _getIt.registerLazySingleton<GetUserApiaries>(
      () => GetUserApiaries(
        _getIt<ApiaryRepository>(),
        _getIt<GetCurrentUserId>(),
      ),
    );

    _getIt.registerLazySingleton<UpdateApiary>(
      () => UpdateApiary(
        _getIt<ApiaryRepository>(),
        _getIt<GetCurrentUserId>(),
      ),
    );

    _getIt.registerLazySingleton<DeleteApiary>(
      () => DeleteApiary(
        _getIt<ApiaryRepository>(),
        _getIt<GetCurrentUserId>(),
      ),
    );

    // BLoC
    _getIt.registerFactory<ApiaryBloc>(
      () => ApiaryBloc(
        getUserApiaries: _getIt<GetUserApiaries>(),
        createApiary: _getIt<CreateApiary>(),
        updateApiary: _getIt<UpdateApiary>(),
        deleteApiary: _getIt<DeleteApiary>(),
        logger: _getIt<Logger>(),
      ),
    );
  }

  /// Récupère une instance du BLoC
  static ApiaryBloc getApiaryBloc() => _getIt<ApiaryBloc>();

  /// Supprime toutes les dépendances du module (pour les tests)
  static void resetApiaryDependencies() {
    if (_getIt.isRegistered<ApiaryBloc>()) {
      _getIt.unregister<ApiaryBloc>();
    }
    if (_getIt.isRegistered<ApiaryRepository>()) {
      _getIt.unregister<ApiaryRepository>();
    }
    if (_getIt.isRegistered<GetCurrentUserId>()) {
      _getIt.unregister<GetCurrentUserId>();
    }
    if (_getIt.isRegistered<CreateApiary>()) {
      _getIt.unregister<CreateApiary>();
    }
    if (_getIt.isRegistered<GetUserApiaries>()) {
      _getIt.unregister<GetUserApiaries>();
    }
    if (_getIt.isRegistered<UpdateApiary>()) {
      _getIt.unregister<UpdateApiary>();
    }
    if (_getIt.isRegistered<DeleteApiary>()) {
      _getIt.unregister<DeleteApiary>();
    }
  }
}
