import 'package:get_it/get_it.dart';
import '../../services/firebase_service.dart';
import '../../services/current_state_service.dart';
import '../../services/sensor_reading_service.dart';
import '../../services/threshold_event_service.dart';
import '../../services/sensor_service.dart';

/// Instance globale de GetIt pour l'injection de dépendances
final GetIt locator = GetIt.instance;

/// Configure toutes les dépendances de l'application
class DependencyInjection {
  static Future<void> init() async {
    // Services de base
    locator.registerLazySingleton<FirebaseService>(() => FirebaseService());

    // Services spécialisés
    locator.registerLazySingleton<CurrentStateService>(
      () => CurrentStateService(locator<FirebaseService>()),
    );

    locator.registerLazySingleton<SensorReadingService>(
      () => SensorReadingService(locator<FirebaseService>()),
    );

    locator.registerLazySingleton<ThresholdEventService>(
      () => ThresholdEventService(locator<FirebaseService>()),
    );

    // Service principal coordinateur
    locator.registerLazySingleton<SensorService>(
      () => SensorService(),
    );

    // Initialiser les services
    await locator<FirebaseService>().initialize();
  }

  /// Nettoie toutes les dépendances
  static void reset() {
    locator.reset();
  }
}
