import '../services/hive_service_coordinator.dart';
import '../../services/firebase_service.dart';
import '../../services/current_state_service.dart';
import '../../services/sensor_reading_service.dart';
import '../../services/threshold_event_service.dart';

/// Factory pour créer les services avec les bonnes dépendances
class ServiceFactory {
  static FirebaseService? _firebaseService;
  static CurrentStateService? _currentStateService;
  static SensorReadingService? _sensorReadingService;
  static ThresholdEventService? _thresholdEventService;
  static HiveServiceCoordinator? _coordinator;

  /// Crée ou retourne l'instance de FirebaseService
  static FirebaseService getFirebaseService() {
    return _firebaseService ??= FirebaseService();
  }

  /// Crée ou retourne l'instance de CurrentStateService
  static CurrentStateService getCurrentStateService() {
    return _currentStateService ??= CurrentStateService(getFirebaseService());
  }

  /// Crée ou retourne l'instance de SensorReadingService
  static SensorReadingService getSensorReadingService() {
    return _sensorReadingService ??= SensorReadingService(getFirebaseService());
  }

  /// Crée ou retourne l'instance de ThresholdEventService
  static ThresholdEventService getThresholdEventService() {
    return _thresholdEventService ??=
        ThresholdEventService(getFirebaseService());
  }

  /// Crée ou retourne l'instance de HiveServiceCoordinator
  static HiveServiceCoordinator getHiveServiceCoordinator() {
    return _coordinator ??= HiveServiceCoordinator(
      firebaseService: getFirebaseService(),
      currentStateService: getCurrentStateService(),
      sensorReadingService: getSensorReadingService(),
      thresholdEventService: getThresholdEventService(),
    );
  }

  /// Initialise tous les services
  static Future<void> initializeServices() async {
    final firebaseService = getFirebaseService();
    await firebaseService.initialize();

    final coordinator = getHiveServiceCoordinator();
    await coordinator.initialize();
  }

  /// Nettoie toutes les instances (pour les tests)
  static void reset() {
    _coordinator?.dispose();
    _firebaseService = null;
    _currentStateService = null;
    _sensorReadingService = null;
    _thresholdEventService = null;
    _coordinator = null;
  }
}
