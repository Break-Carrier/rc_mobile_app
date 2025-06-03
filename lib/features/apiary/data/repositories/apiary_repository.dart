import 'package:flutter/foundation.dart';
import '../../../../models/apiary.dart';
import '../../../../models/hive.dart';
import '../../../../services/sensor_service.dart';
import '../../domain/repositories/apiary_repository_interface.dart';

/// Implémentation du repository pour les ruchers
class ApiaryRepository implements IApiaryRepository {
  final SensorService _sensorService;

  ApiaryRepository({SensorService? sensorService})
      : _sensorService = sensorService ?? SensorService();

  @override
  Future<List<Apiary>> getApiaries() async {
    try {
      return await _sensorService.getApiaries();
    } catch (e) {
      debugPrint('❌ Error getting apiaries: $e');
      return [];
    }
  }

  @override
  Future<Apiary?> getApiaryById(String apiaryId) async {
    try {
      // Récupérer tous les ruchers et chercher celui avec l'ID correspondant
      final apiaries = await _sensorService.getApiaries();
      return apiaries.firstWhere(
        (apiary) => apiary.id == apiaryId,
        orElse: () => throw Exception('Apiary not found with ID: $apiaryId'),
      );
    } catch (e) {
      debugPrint('❌ Error getting apiary by ID: $e');
      return null;
    }
  }

  @override
  Future<List<Hive>> getHivesForApiary(String apiaryId) async {
    try {
      return await _sensorService.getHivesForApiary(apiaryId);
    } catch (e) {
      debugPrint('❌ Error getting hives for apiary: $e');
      return [];
    }
  }

  @override
  Future<String?> addApiary(Apiary apiary) async {
    try {
      // Convertir l'objet en Map pour le stocker
      final data = apiary.toMap();

      // TODO: Implémenter l'ajout d'un rucher dans le SensorService
      // Pour l'instant, c'est un stub
      throw UnimplementedError(
          'La fonction addApiary n\'est pas encore implémentée');

      // Retourner l'ID du rucher créé
      // return createdId;
    } catch (e) {
      debugPrint('❌ Error adding apiary: $e');
      return null;
    }
  }

  @override
  Future<bool> updateApiary(String apiaryId, Apiary apiary) async {
    try {
      // Convertir l'objet en Map pour le stocker
      final data = apiary.toMap();

      // TODO: Implémenter la mise à jour d'un rucher dans le SensorService
      // Pour l'instant, c'est un stub
      throw UnimplementedError(
          'La fonction updateApiary n\'est pas encore implémentée');

      // return true;
    } catch (e) {
      debugPrint('❌ Error updating apiary: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteApiary(String apiaryId) async {
    try {
      // TODO: Implémenter la suppression d'un rucher dans le SensorService
      // Pour l'instant, c'est un stub
      throw UnimplementedError(
          'La fonction deleteApiary n\'est pas encore implémentée');

      // return true;
    } catch (e) {
      debugPrint('❌ Error deleting apiary: $e');
      return false;
    }
  }

  @override
  Future<String?> addHiveToApiary(String apiaryId, Hive hive) async {
    try {
      // Convertir l'objet en Map pour le stocker
      final data = hive.toMap();

      // TODO: Implémenter l'ajout d'une ruche à un rucher dans le SensorService
      // Pour l'instant, c'est un stub
      throw UnimplementedError(
          'La fonction addHiveToApiary n\'est pas encore implémentée');

      // return hiveId;
    } catch (e) {
      debugPrint('❌ Error adding hive to apiary: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteHiveFromApiary(String apiaryId, String hiveId) async {
    try {
      // TODO: Implémenter la suppression d'une ruche d'un rucher dans le SensorService
      // Pour l'instant, c'est un stub
      throw UnimplementedError(
          'La fonction deleteHiveFromApiary n\'est pas encore implémentée');

      // return true;
    } catch (e) {
      debugPrint('❌ Error deleting hive from apiary: $e');
      return false;
    }
  }
}
