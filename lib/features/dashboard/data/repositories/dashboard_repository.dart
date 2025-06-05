import 'package:flutter/foundation.dart';
import '../../../sensor/domain/entities/sensor_reading.dart';
import '../../../../core/factories/service_factory.dart';
import '../../../sensor/domain/entities/time_filter.dart';

class DashboardRepository {
  final FirebaseService _firebaseService;
  final coordinator = ServiceFactory.getHiveServiceCoordinator();

  DashboardRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? ServiceFactory.firebaseService;

  /// Récupère la température moyenne pour toutes les ruches d'un rucher
  Future<List<SensorReading>> getAverageTemperatureForApiary(
      String apiaryId, TimeFilter timeFilter) async {
    try {
      await _firebaseService.initialize();

      // TODO: Implémenter la récupération des données moyennes depuis Firebase
      // Pour l'instant, retourner une liste vide
      return [];
    } catch (e) {
      debugPrint('❌ Error calculating average temperature: $e');
      return [];
    }
  }
}
