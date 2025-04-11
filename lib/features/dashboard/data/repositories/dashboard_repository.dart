import 'package:flutter/foundation.dart';
import '../../../../models/sensor_reading.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/sensor_reading_service.dart';
import '../../../../models/time_filter.dart';

class DashboardRepository {
  final FirebaseService _firebaseService;

  DashboardRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  /// Récupère la température moyenne pour toutes les ruches d'un rucher
  Future<List<SensorReading>> getAverageTemperatureForApiary(
      String apiaryId, TimeFilter timeFilter) async {
    try {
      await _firebaseService.initialize();
    } catch (e) {
      debugPrint('❌ Impossible d\'initialiser Firebase: $e');
    }

    try {
      // Récupérer toutes les ruches du rucher
      final hivesData =
          await _firebaseService.getData('apiaries/$apiaryId/hives');
      if (hivesData == null || hivesData.isEmpty) {
        debugPrint('⚠️ No hives found for apiary $apiaryId');
        return [];
      }

      // Récupérer les IDs de toutes les ruches
      final hiveIds = hivesData.keys.toList();
      debugPrint('📊 Found ${hiveIds.length} hives in apiary $apiaryId');

      // Liste pour stocker toutes les lectures de capteurs des ruches
      final allReadingsByTimestamp = <DateTime, List<double>>{};

      // Pour chaque ruche, récupérer les lectures du capteur de température
      for (final hiveId in hiveIds) {
        try {
          // Créer un SensorReadingService temporaire pour cette ruche
          final readingService = SensorReadingService(_firebaseService);
          readingService.setCurrentHive(hiveId);
          readingService.setTimeFilter(timeFilter);

          // Récupérer les lectures
          final readings = await readingService.getSensorReadings();

          // Filtrer pour ne garder que les lectures de température
          final tempReadings =
              readings.where((r) => r.type == 'temperature').toList();

          // Ajouter les lectures à notre map par timestamp
          for (final reading in tempReadings) {
            final roundedTime = DateTime(
              reading.timestamp.year,
              reading.timestamp.month,
              reading.timestamp.day,
              reading.timestamp.hour,
              reading.timestamp.minute,
            );

            if (!allReadingsByTimestamp.containsKey(roundedTime)) {
              allReadingsByTimestamp[roundedTime] = [];
            }

            allReadingsByTimestamp[roundedTime]!.add(reading.value);
          }
        } catch (e) {
          debugPrint('❌ Error getting readings for hive $hiveId: $e');
          // Continue avec la prochaine ruche en cas d'erreur
        }
      }

      // Transformer la map en liste de SensorReading avec des moyennes
      final averageReadings = <SensorReading>[];

      allReadingsByTimestamp.forEach((timestamp, values) {
        if (values.isNotEmpty) {
          // Calculer la moyenne des valeurs pour ce timestamp
          final average = values.reduce((a, b) => a + b) / values.length;

          averageReadings.add(SensorReading(
            id: 'avg_${timestamp.millisecondsSinceEpoch}',
            sensorId: 'average_sensor',
            type: 'temperature',
            value: average,
            unit: '°C',
            timestamp: timestamp,
            metadata: {'source': 'average', 'samples': values.length},
          ));
        }
      });

      // Trier par timestamp
      averageReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      debugPrint(
          '📊 Generated ${averageReadings.length} average temperature readings');
      return averageReadings;
    } catch (e) {
      debugPrint('❌ Error calculating average temperature: $e');
      return [];
    }
  }
}
