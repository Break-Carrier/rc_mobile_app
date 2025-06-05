import '../../features/sensor/domain/entities/sensor_reading.dart';
import '../../features/sensor/domain/entities/hive.dart';
import '../../features/sensor/domain/entities/apiary.dart';

/// Données mock pour les tests et le développement
class MockData {
  static final List<SensorReading> _sampleReadings = [
    SensorReading(
      id: '1',
      hiveId: 'hive_1',
      temperature: 35.5,
      humidity: 60.0,
      weight: 45.2,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    SensorReading(
      id: '2',
      hiveId: 'hive_1',
      temperature: 35.8,
      humidity: 58.5,
      weight: 45.3,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    SensorReading(
      id: '3',
      hiveId: 'hive_1',
      temperature: 35.2,
      humidity: 62.0,
      weight: 45.1,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    SensorReading(
      id: '4',
      hiveId: 'hive_1',
      temperature: 35.9,
      humidity: 59.5,
      weight: 45.4,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    SensorReading(
      id: '5',
      hiveId: 'hive_1',
      temperature: 35.6,
      humidity: 61.0,
      weight: 45.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    SensorReading(
      id: '6',
      hiveId: 'hive_1',
      temperature: 35.3,
      humidity: 63.0,
      weight: 44.9,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  /// Lectures de capteurs échantillons
  static List<SensorReading> get sampleReadings =>
      List.unmodifiable(_sampleReadings);

  /// Ruches échantillons
  static final List<Hive> _sampleHives = [
    Hive(
      id: 'hive_1',
      name: 'Ruche Alpha',
      apiaryId: 'apiary_1',
      description: 'Ruche principale du rucher',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Hive(
      id: 'hive_2',
      name: 'Ruche Beta',
      apiaryId: 'apiary_1',
      description: 'Ruche secondaire',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    Hive(
      id: 'hive_3',
      name: 'Ruche Gamma',
      apiaryId: 'apiary_2',
      description: 'Nouvelle ruche',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<Hive> get sampleHives => List.unmodifiable(_sampleHives);

  /// Ruchers échantillons
  static final List<Apiary> _sampleApiaries = [
    Apiary(
      id: 'apiary_1',
      name: 'Rucher Principal',
      location: 'Jardin du château',
      description: 'Le rucher principal avec nos meilleures ruches',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
      hiveIds: ['hive_1', 'hive_2'],
    ),
    Apiary(
      id: 'apiary_2',
      name: 'Rucher Annexe',
      location: 'Prairie sud',
      description: 'Rucher annexe pour l\'expansion',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      hiveIds: ['hive_3'],
    ),
  ];

  static List<Apiary> get sampleApiaries => List.unmodifiable(_sampleApiaries);

  /// Obtient des lectures échantillons pour une ruche et période donnée
  static List<SensorReading> getReadingsForHive(String hiveId) {
    return _sampleReadings
        .where((reading) => reading.hiveId == hiveId)
        .toList();
  }
}
