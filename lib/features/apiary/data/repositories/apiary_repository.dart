import 'package:flutter/foundation.dart';
import '../../../../core/models/apiary.dart';
import '../../../../core/models/hive.dart';
import '../../../../core/factories/service_factory.dart';
import '../../domain/repositories/apiary_repository_interface.dart';

/// Implémentation du repository pour les ruchers
class ApiaryRepository implements IApiaryRepository {
  final coordinator = ServiceFactory.getHiveServiceCoordinator();

  @override
  Future<List<Apiary>> getApiaries() async {
    try {
      return await coordinator.getApiaries();
    } catch (e) {
      debugPrint('❌ Error getting apiaries: $e');
      return [];
    }
  }

  @override
  Future<Apiary?> getApiaryById(String apiaryId) async {
    try {
      final apiaries = await coordinator.getApiaries();
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
      return await coordinator.getHivesForApiary(apiaryId);
    } catch (e) {
      debugPrint('❌ Error getting hives for apiary: $e');
      return [];
    }
  }

  @override
  Future<String?> addApiary(Apiary apiary) async {
    try {
      // TODO: Implémenter l'ajout d'un rucher
      throw UnimplementedError(
          'La fonction addApiary n\'est pas encore implémentée');
    } catch (e) {
      debugPrint('❌ Error adding apiary: $e');
      return null;
    }
  }

  @override
  Future<bool> updateApiary(String apiaryId, Apiary apiary) async {
    try {
      // TODO: Implémenter la mise à jour d'un rucher
      throw UnimplementedError(
          'La fonction updateApiary n\'est pas encore implémentée');
    } catch (e) {
      debugPrint('❌ Error updating apiary: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteApiary(String apiaryId) async {
    try {
      // TODO: Implémenter la suppression d'un rucher
      throw UnimplementedError(
          'La fonction deleteApiary n\'est pas encore implémentée');
    } catch (e) {
      debugPrint('❌ Error deleting apiary: $e');
      return false;
    }
  }

  @override
  Future<String?> addHiveToApiary(String apiaryId, Hive hive) async {
    try {
      // TODO: Implémenter l'ajout d'une ruche à un rucher
      throw UnimplementedError(
          'La fonction addHiveToApiary n\'est pas encore implémentée');
    } catch (e) {
      debugPrint('❌ Error adding hive to apiary: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteHiveFromApiary(String apiaryId, String hiveId) async {
    try {
      // TODO: Implémenter la suppression d'une ruche d'un rucher
      throw UnimplementedError(
          'La fonction deleteHiveFromApiary n\'est pas encore implémentée');
    } catch (e) {
      debugPrint('❌ Error deleting hive from apiary: $e');
      return false;
    }
  }
}
