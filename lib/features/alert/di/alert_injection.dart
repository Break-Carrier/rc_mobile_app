import 'package:get_it/get_it.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import '../../../../core/config/app_config.dart';
import '../domain/repositories/alert_repository_interface.dart';
import '../domain/usecases/get_alerts_usecase.dart';
import '../domain/usecases/manage_alert_usecase.dart';
import '../data/repositories/alert_repository.dart';
import '../presentation/bloc/alert_bloc.dart';

/// Injection de dépendances pour le module d'alertes
class AlertInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Configure toutes les dépendances du module d'alertes
  static void setupAlertDependencies() {
    // Logger
    if (!_getIt.isRegistered<Logger>()) {
      _getIt.registerLazySingleton<Logger>(
        () => Logger(
          printer: PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.none,
          ),
        ),
      );
    }

    // Firebase Database
    if (!_getIt.isRegistered<FirebaseDatabase>()) {
      _getIt.registerLazySingleton<FirebaseDatabase>(
        () => FirebaseDatabase.instance,
      );
    }

    // Repository
    _getIt.registerLazySingleton<IAlertRepository>(
      () => AlertRepository(
        database: _getIt<FirebaseDatabase>(),
        basePath: AppConfig.firebaseBasePath,
        logger: _getIt<Logger>(),
      ),
    );

    // Use Cases
    _getIt.registerLazySingleton<GetAlertsUseCase>(
      () => GetAlertsUseCase(_getIt<IAlertRepository>()),
    );

    _getIt.registerLazySingleton<ManageAlertUseCase>(
      () => ManageAlertUseCase(_getIt<IAlertRepository>()),
    );

    // BLoC
    _getIt.registerFactory<AlertBloc>(
      () => AlertBloc(
        getAlertsUseCase: _getIt<GetAlertsUseCase>(),
        manageAlertUseCase: _getIt<ManageAlertUseCase>(),
        alertRepository: _getIt<IAlertRepository>(),
      ),
    );
  }

  /// Récupère le BLoC d'alertes
  static AlertBloc getAlertBloc() {
    return _getIt<AlertBloc>();
  }

  /// Récupère le repository d'alertes
  static IAlertRepository getAlertRepository() {
    return _getIt<IAlertRepository>();
  }

  /// Récupère le use case de récupération d'alertes
  static GetAlertsUseCase getGetAlertsUseCase() {
    return _getIt<GetAlertsUseCase>();
  }

  /// Récupère le use case de gestion d'alertes
  static ManageAlertUseCase getManageAlertUseCase() {
    return _getIt<ManageAlertUseCase>();
  }

  /// Réinitialise les dépendances du module d'alertes
  static void resetAlertDependencies() {
    // Nettoyer le BLoC s'il existe
    if (_getIt.isRegistered<AlertBloc>()) {
      final bloc = _getIt<AlertBloc>();
      bloc.close();
      _getIt.unregister<AlertBloc>();
    }

    // Nettoyer le repository s'il existe
    if (_getIt.isRegistered<IAlertRepository>()) {
      final repository = _getIt<IAlertRepository>();
      repository.dispose();
      _getIt.unregister<IAlertRepository>();
    }

    // Nettoyer les use cases
    if (_getIt.isRegistered<GetAlertsUseCase>()) {
      _getIt.unregister<GetAlertsUseCase>();
    }

    if (_getIt.isRegistered<ManageAlertUseCase>()) {
      _getIt.unregister<ManageAlertUseCase>();
    }
  }
}
