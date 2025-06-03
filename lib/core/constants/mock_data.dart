import '../../models/sensor_reading.dart';
import '../../models/hive.dart';
import '../../models/apiary.dart';

class MockData {
  static List<SensorReading> generateMockReadings({
    String? hiveId,
    Duration? timeRange,
  }) {
    final now = DateTime.now();
    final startTime = timeRange != null
        ? now.subtract(timeRange)
        : now.subtract(const Duration(hours: 24));

    final readings = <SensorReading>[];
    final interval = timeRange != null
        ? timeRange.inMinutes ~/ 50
        : 30; // 30 minutes interval

    for (var i = 0; i < 50; i++) {
      final timestamp = startTime.add(Duration(minutes: i * interval));

      // Simulate realistic temperature and humidity patterns
      final hourOfDay = timestamp.hour;
      final baseTemp = _getBaseTemperature(hourOfDay);
      final baseHumidity = _getBaseHumidity(hourOfDay);

      // Generate temperature reading
      readings.add(SensorReading(
        id: 'mock_temp_${i}_$hiveId',
        sensorId: 'sensor_temp_${hiveId ?? 'default'}',
        type: 'temperature',
        value: baseTemp + (_randomVariation() * 2),
        unit: '°C',
        timestamp: timestamp,
      ));

      // Generate humidity reading
      readings.add(SensorReading(
        id: 'mock_humid_${i}_$hiveId',
        sensorId: 'sensor_humid_${hiveId ?? 'default'}',
        type: 'humidity',
        value: baseHumidity + (_randomVariation() * 5),
        unit: '%',
        timestamp: timestamp,
      ));
    }

    return readings;
  }

  static double _getBaseTemperature(int hour) {
    // Simulate daily temperature pattern (warmer during day)
    if (hour >= 6 && hour <= 18) {
      return 24.0 + (hour - 6) * 0.3; // Gradual increase during day
    } else {
      return 22.0 + _randomVariation(); // Cooler at night
    }
  }

  static double _getBaseHumidity(int hour) {
    // Simulate daily humidity pattern (higher at night/morning)
    if (hour >= 22 || hour <= 6) {
      return 65.0 + _randomVariation() * 2;
    } else {
      return 55.0 + _randomVariation() * 3;
    }
  }

  static double _randomVariation() {
    return (DateTime.now().millisecondsSinceEpoch % 1000 - 500) / 1000;
  }

  static List<Hive> getMockHives() {
    final now = DateTime.now();
    return [
      Hive(
        id: 'mock_hive_01',
        name: 'Ruche Alpha',
        apiaryId: 'mock_apiary_01',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        recentReadings: [],
      ),
      Hive(
        id: 'mock_hive_02',
        name: 'Ruche Beta',
        apiaryId: 'mock_apiary_01',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
        recentReadings: [],
      ),
      Hive(
        id: 'mock_hive_03',
        name: 'Ruche Gamma',
        apiaryId: 'mock_apiary_02',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        recentReadings: [],
      ),
    ];
  }

  static List<Apiary> getMockApiaries() {
    final now = DateTime.now();
    return [
      Apiary(
        id: 'mock_apiary_01',
        name: 'Rucher Principal',
        location: 'Jardin de la Maison',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
        hiveIds: ['mock_hive_01', 'mock_hive_02'],
      ),
      Apiary(
        id: 'mock_apiary_02',
        name: 'Rucher Secondaire',
        location: 'Prairie du Nord',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
        hiveIds: ['mock_hive_03'],
      ),
    ];
  }

  static SensorReading? getLatestReading(String hiveId) {
    final readings = generateMockReadings(hiveId: hiveId);
    return readings.isNotEmpty ? readings.last : null;
  }
}
