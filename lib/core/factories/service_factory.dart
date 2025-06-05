import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../features/sensor/domain/entities/current_state.dart';
import '../../features/sensor/domain/entities/sensor_reading.dart';
import '../../features/sensor/domain/entities/threshold_event.dart';
import '../../features/sensor/domain/entities/time_filter.dart';
import '../../features/apiary/data/injection/apiary_injection.dart';
import '../../features/hive/data/injection/hive_injection.dart';
import '../config/app_config.dart';
import '../services/hive_service_coordinator.dart';

/// Factory pour créer les services avec leurs dépendances
class ServiceFactory {
  static FirebaseService? _firebaseService;
  static CurrentStateService? _currentStateService;
  static SensorReadingService? _sensorReadingService;
  static ThresholdEventService? _thresholdEventService;
  static HiveServiceCoordinator? _coordinator;
  static bool _isInitialized = false;

  /// Service Firebase partagé
  static FirebaseService get firebaseService {
    _firebaseService ??= FirebaseService(
      database: FirebaseDatabase.instance,
      basePath: AppConfig.firebaseBasePath,
    );
    return _firebaseService!;
  }

  /// Service CurrentState avec Stream<CurrentState?>
  static CurrentStateService get currentStateService {
    _currentStateService ??= CurrentStateService(
      database: firebaseService.database,
      basePath: firebaseService.basePath,
    );
    return _currentStateService!;
  }

  /// Service SensorReading avec TimeFilter
  static SensorReadingService get sensorReadingService {
    _sensorReadingService ??= SensorReadingService(
      database: firebaseService.database,
      basePath: firebaseService.basePath,
    );
    return _sensorReadingService!;
  }

  /// Service ThresholdEvent
  static ThresholdEventService get thresholdEventService {
    _thresholdEventService ??= ThresholdEventService(
      database: firebaseService.database,
      basePath: firebaseService.basePath,
    );
    return _thresholdEventService!;
  }

  /// Coordinateur de services de ruche
  static HiveServiceCoordinator getHiveServiceCoordinator() {
    return _coordinator ??= HiveServiceCoordinator.create();
  }

  /// Initialise tous les services
  static Future<void> initializeServices() async {
    if (_isInitialized) return;

    // Initialiser les dépendances globales
    _setupGlobalDependencies();

    // Initialiser les modules
    ApiaryInjection.setupApiaryDependencies();
    HiveInjection.setupHiveDependencies();

    final coordinator = getHiveServiceCoordinator();
    await coordinator.initialize();

    _isInitialized = true;
  }

  /// Configure les dépendances globales (Firebase, Logger, etc.)
  static void _setupGlobalDependencies() {
    final getIt = GetIt.instance;

    // Firebase Database
    if (!getIt.isRegistered<FirebaseDatabase>()) {
      getIt.registerLazySingleton<FirebaseDatabase>(
        () => FirebaseDatabase.instance,
      );
    }

    // Logger
    if (!getIt.isRegistered<Logger>()) {
      getIt.registerLazySingleton<Logger>(
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
  }

  /// Nettoyage pour les tests
  static void reset() {
    _coordinator?.dispose();
    ApiaryInjection.resetApiaryDependencies();
    HiveInjection.resetHiveDependencies();
    _firebaseService = null;
    _currentStateService = null;
    _sensorReadingService = null;
    _thresholdEventService = null;
    _coordinator = null;
    _isInitialized = false;
  }
}

/// Service Firebase de base
class FirebaseService {
  final FirebaseDatabase database;
  final String basePath;

  FirebaseService({required this.database, required this.basePath});

  bool get isConnected => true; // Simplification pour l'instant

  Future<void> initialize() async {
    // Configuration Firebase si nécessaire
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await database.ref('$basePath/$path').update(data);
  }

  Future<bool> checkDirectConnection() async {
    try {
      await database.ref('.info/connected').once();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Service pour CurrentState
class CurrentStateService {
  final FirebaseDatabase database;
  final String basePath;
  String? _currentHiveId;

  CurrentStateService({required this.database, required this.basePath});

  void setCurrentHive(String hiveId) {
    _currentHiveId = hiveId;
  }

  Stream<CurrentState?> get stateStream {
    if (_currentHiveId == null) return Stream.value(null);

    return database
        .ref('$basePath/hives/$_currentHiveId/current_state')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return null;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return CurrentState(
        hiveId: _currentHiveId!,
        temperature: (data['temperature'] as num?)?.toDouble(),
        humidity: (data['humidity'] as num?)?.toDouble(),
        weight: (data['weight'] as num?)?.toDouble(),
        isOnline: data['is_online'] == true,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        ),
        metadata: data['metadata'] as Map<String, dynamic>?,
      );
    });
  }

  Future<CurrentState?> getCurrentState() async {
    if (_currentHiveId == null) return null;

    final snapshot = await database
        .ref('$basePath/hives/$_currentHiveId/current_state')
        .once();

    if (snapshot.snapshot.value == null) return null;

    final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
    return CurrentState(
      hiveId: _currentHiveId!,
      temperature: (data['temperature'] as num?)?.toDouble(),
      humidity: (data['humidity'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      isOnline: data['is_online'] == true,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Service pour SensorReading
class SensorReadingService {
  final FirebaseDatabase database;
  final String basePath;
  String? _currentHiveId;
  TimeFilter _timeFilter = TimeFilter.oneDay;

  SensorReadingService({required this.database, required this.basePath});

  void setCurrentHive(String hiveId) {
    _currentHiveId = hiveId;
  }

  Future<void> setTimeFilter(TimeFilter filter) async {
    _timeFilter = filter;
  }

  Stream<List<SensorReading>> get readingsStream {
    if (_currentHiveId == null) return Stream.value([]);

    return database
        .ref('$basePath/hives/$_currentHiveId/sensor_data')
        .orderByChild('timestamp')
        .startAt(_timeFilter.getStartDate().millisecondsSinceEpoch)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <SensorReading>[];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final readings = <SensorReading>[];

      data.forEach((key, value) {
        final readingData = Map<String, dynamic>.from(value as Map);
        readings.add(SensorReading(
          id: key,
          hiveId: _currentHiveId!,
          temperature: (readingData['temperature'] as num?)?.toDouble(),
          humidity: (readingData['humidity'] as num?)?.toDouble(),
          weight: (readingData['weight'] as num?)?.toDouble(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            readingData['timestamp'] as int,
          ),
          metadata: readingData['metadata'] as Map<String, dynamic>?,
        ));
      });

      return readings;
    });
  }
}

/// Service pour ThresholdEvent
class ThresholdEventService {
  final FirebaseDatabase database;
  final String basePath;
  String? _currentHiveId;

  ThresholdEventService({required this.database, required this.basePath});

  void setCurrentHive(String hiveId) {
    _currentHiveId = hiveId;
  }

  Stream<List<ThresholdEvent>> get eventsStream {
    if (_currentHiveId == null) return Stream.value([]);

    return database
        .ref('$basePath/hives/$_currentHiveId/threshold_events')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <ThresholdEvent>[];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final events = <ThresholdEvent>[];

      data.forEach((key, value) {
        final eventData = Map<String, dynamic>.from(value as Map);
        events.add(ThresholdEvent(
          id: key,
          hiveId: _currentHiveId!,
          type: eventData['type'] as String,
          value: (eventData['value'] as num).toDouble(),
          threshold: (eventData['threshold'] as num).toDouble(),
          severity: eventData['severity'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            eventData['timestamp'] as int,
          ),
          isResolved: eventData['is_resolved'] == true,
          metadata: eventData['metadata'] as Map<String, dynamic>?,
        ));
      });

      return events;
    });
  }
}
