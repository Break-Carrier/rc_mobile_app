import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../apiary/domain/repositories/apiary_repository.dart';
import '../../../apiary/domain/usecases/get_current_user_id.dart';
import '../../domain/repositories/hive_repository.dart';
import '../../domain/usecases/create_hive.dart';
import '../../domain/usecases/delete_hive.dart';
import '../../domain/usecases/get_apiary_hives.dart';
import '../repositories/firebase_hive_repository.dart';
import '../../presentation/bloc/hive_bloc.dart';

/// Configuration de l'injection de dépendances pour le module Ruches
class HiveInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Enregistre toutes les dépendances du module Ruches
  static void setupHiveDependencies() {
    // Repository
    _getIt.registerLazySingleton<HiveRepository>(
      () => FirebaseHiveRepository(
        _getIt<FirebaseDatabase>(),
        _getIt<Logger>(),
      ),
    );

    // Use Cases CRUD
    _getIt.registerLazySingleton<CreateHive>(
      () => CreateHive(
        _getIt<HiveRepository>(),
        _getIt<ApiaryRepository>(),
        _getIt<GetCurrentUserId>(),
      ),
    );

    _getIt.registerLazySingleton<GetApiaryHives>(
      () => GetApiaryHives(
        _getIt<HiveRepository>(),
        _getIt<ApiaryRepository>(),
        _getIt<GetCurrentUserId>(),
      ),
    );

    _getIt.registerLazySingleton<DeleteHive>(
      () => DeleteHive(
        _getIt<HiveRepository>(),
        _getIt<ApiaryRepository>(),
        _getIt<GetCurrentUserId>(),
      ),
    );

    // BLoC
    _getIt.registerFactory<HiveBloc>(
      () => HiveBloc(
        getApiaryHives: _getIt<GetApiaryHives>(),
        createHive: _getIt<CreateHive>(),
        deleteHive: _getIt<DeleteHive>(),
        logger: _getIt<Logger>(),
      ),
    );
  }

  /// Récupère une instance du BLoC
  static HiveBloc getHiveBloc() => _getIt<HiveBloc>();

  /// Supprime toutes les dépendances du module (pour les tests)
  static void resetHiveDependencies() {
    if (_getIt.isRegistered<HiveBloc>()) {
      _getIt.unregister<HiveBloc>();
    }
    if (_getIt.isRegistered<HiveRepository>()) {
      _getIt.unregister<HiveRepository>();
    }
    if (_getIt.isRegistered<CreateHive>()) {
      _getIt.unregister<CreateHive>();
    }
    if (_getIt.isRegistered<GetApiaryHives>()) {
      _getIt.unregister<GetApiaryHives>();
    }
    if (_getIt.isRegistered<DeleteHive>()) {
      _getIt.unregister<DeleteHive>();
    }
  }
}
