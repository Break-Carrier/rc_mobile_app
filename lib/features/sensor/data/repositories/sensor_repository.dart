import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../services/firebase_service.dart';
import '../../../../utils/map_converter.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/repositories/sensor_repository_interface.dart';
import '../models/sensor_reading_model.dart';

/// Implémentation du repository pour les lectures de capteurs
class SensorRepository implements ISensorRepository {
  final FirebaseService _firebaseService;

  SensorRepository({FirebaseService? firebaseService}) 
      : _firebaseService = firebaseService ?? FirebaseService();

  @override
  Future<List<SensorReading>> getLatestReadings(String sensorId, {int limit = 10}) async {
    try {
      final path = 'sensors/$sensorId/readings';
      final data = await _firebaseService.getLatestEntries(path, limit);

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<SensorReadingModel> readings = [];
      data.forEach((key, value) {
        try {
          final reading = SensorReadingModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);
          readings.add(reading);
        } catch (e) {
          debugPrint('⚠️ Error parsing sensor reading: $e');
        }
      });

      // Trier par timestamp (plus récent en premier)
      readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return readings;
    } catch (e) {
      debugPrint('❌ Error fetching sensor readings: $e');
      throw Exception('Erreur lors de la récupération des lectures de capteurs: $e');
    }
  }

  @override
  Future<List<SensorReading>> getReadingsByTimeRange(
      String sensorId, DateTime startTime, DateTime endTime) async {
    try {
      // Pour l'instant, récupérons toutes les lectures récentes et filtrons-les
      // Dans une version future, on pourrait utiliser les requêtes Firebase plus avancées
      final path = 'sensors/$sensorId/readings';
      
      // Calculer une limite appropriée basée sur la plage de temps
      // Estimation simple: une lecture toutes les 5 minutes
      final differenceInMinutes = endTime.difference(startTime).inMinutes;
      final estimatedLimit = (differenceInMinutes / 5).ceil();
      final limit = estimatedLimit < 10 ? 10 : estimatedLimit > 1000 ? 1000 : estimatedLimit;
      
      final data = await _firebaseService.getLatestEntries(path, limit);

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<SensorReadingModel> allReadings = [];
      data.forEach((key, value) {
        try {
          final reading = SensorReadingModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);
          allReadings.add(reading);
        } catch (e) {
          debugPrint('⚠️ Error parsing sensor reading: $e');
        }
      });

      // Filtrer par plage de temps
      final filteredReadings = allReadings
          .where((reading) =>
              reading.timestamp.isAfter(startTime) &&
              reading.timestamp.isBefore(endTime))
          .toList();

      // Trier par timestamp (plus récent en premier)
      filteredReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return filteredReadings;
    } catch (e) {
      debugPrint('❌ Error fetching sensor readings by time range: $e');
      throw Exception('Erreur lors de la récupération des lectures de capteurs par plage de temps: $e');
    }
  }

  @override
  Future<List<SensorReading>> getLatestReadingsForHive(String hiveId, {int limit = 10}) async {
    try {
      final path = 'hives/$hiveId/sensor_readings';
      final data = await _firebaseService.getLatestEntries(path, limit);

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<SensorReadingModel> readings = [];
      data.forEach((key, value) {
        try {
          final reading = SensorReadingModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);
          readings.add(reading);
        } catch (e) {
          debugPrint('⚠️ Error parsing sensor reading: $e');
        }
      });

      // Trier par timestamp (plus récent en premier)
      readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return readings;
    } catch (e) {
      debugPrint('❌ Error fetching hive sensor readings: $e');
      throw Exception('Erreur lors de la récupération des lectures de capteurs de la ruche: $e');
    }
  }

  @override
  Future<List<SensorReading>> getReadingsForHiveByTimeRange(
      String hiveId, DateTime startTime, DateTime endTime) async {
    try {
      // Pour l'instant, récupérons toutes les lectures récentes et filtrons-les
      final path = 'hives/$hiveId/sensor_readings';
      
      // Calculer une limite appropriée basée sur la plage de temps
      final differenceInMinutes = endTime.difference(startTime).inMinutes;
      final estimatedLimit = (differenceInMinutes / 5).ceil();
      final limit = estimatedLimit < 10 ? 10 : estimatedLimit > 1000 ? 1000 : estimatedLimit;
      
      final data = await _firebaseService.getLatestEntries(path, limit);

      if (data == null || data.isEmpty) {
        return [];
      }

      final List<SensorReadingModel> allReadings = [];
      data.forEach((key, value) {
        try {
          final reading = SensorReadingModel.fromRealtimeDB(
              value as Map<String, dynamic>, key);
          allReadings.add(reading);
        } catch (e) {
          debugPrint('⚠️ Error parsing sensor reading: $e');
        }
      });

      // Filtrer par plage de temps
      final filteredReadings = allReadings
          .where((reading) =>
              reading.timestamp.isAfter(startTime) &&
              reading.timestamp.isBefore(endTime))
          .toList();

      // Trier par timestamp (plus récent en premier)
      filteredReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return filteredReadings;
    } catch (e) {
      debugPrint('❌ Error fetching hive sensor readings by time range: $e');
      throw Exception('Erreur lors de la récupération des lectures de capteurs de la ruche par plage de temps: $e');
    }
  }

  @override
  Stream<List<SensorReading>> streamReadings(String sensorId) {
    try {
      final path = 'sensors/$sensorId/readings';
      final limit = 20; // Nombre de lectures à suivre

      return _firebaseService.getLatestEntriesStream(path, limit)
          .map((event) {
            if (!event.snapshot.exists) {
              return <SensorReadingModel>[];
            }
            
            try {
              if (event.snapshot.value is Map) {
                final rawData = event.snapshot.value as Map<Object?, Object?>;
                final Map<String, dynamic> data = 
                    MapConverter.convertToStringDynamicMap(rawData);
                
                final List<SensorReadingModel> readings = [];
                data.forEach((key, value) {
                  try {
                    final reading = SensorReadingModel.fromRealtimeDB(
                        value as Map<String, dynamic>, key);
                    readings.add(reading);
                  } catch (e) {
                    debugPrint('⚠️ Error parsing sensor reading: $e');
                  }
                });

                // Trier par timestamp (plus récent en premier)
                readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                
                return readings;
              } else {
                return <SensorReadingModel>[];
              }
            } catch (e) {
              debugPrint('❌ Error processing sensor readings stream: $e');
              throw Exception('Erreur lors du traitement du flux de lectures: $e');
            }
          });
    } catch (e) {
      debugPrint('❌ Error setting up sensor readings stream: $e');
      return Stream.value(<SensorReadingModel>[]);
    }
  }

  @override
  Stream<List<SensorReading>> streamReadingsForHive(String hiveId) {
    try {
      final path = 'hives/$hiveId/sensor_readings';
      final limit = 30; // Nombre de lectures à suivre

      return _firebaseService.getLatestEntriesStream(path, limit)
          .map((event) {
            if (!event.snapshot.exists) {
              return <SensorReadingModel>[];
            }
            
            try {
              if (event.snapshot.value is Map) {
                final rawData = event.snapshot.value as Map<Object?, Object?>;
                final Map<String, dynamic> data = 
                    MapConverter.convertToStringDynamicMap(rawData);
                
                final List<SensorReadingModel> readings = [];
                data.forEach((key, value) {
                  try {
                    final reading = SensorReadingModel.fromRealtimeDB(
                        value as Map<String, dynamic>, key);
                    readings.add(reading);
                  } catch (e) {
                    debugPrint('⚠️ Error parsing sensor reading: $e');
                  }
                });

                // Trier par timestamp (plus récent en premier)
                readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                
                return readings;
              } else {
                return <SensorReadingModel>[];
              }
            } catch (e) {
              debugPrint('❌ Error processing hive sensor readings stream: $e');
              throw Exception('Erreur lors du traitement du flux de lectures de la ruche: $e');
            }
          });
    } catch (e) {
      debugPrint('❌ Error setting up hive sensor readings stream: $e');
      return Stream.value(<SensorReadingModel>[]);
    }
  }
}
