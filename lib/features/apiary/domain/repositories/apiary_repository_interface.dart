import '../../../sensor/domain/entities/apiary.dart';
import '../../../sensor/domain/entities/hive.dart';

/// Interface définissant les méthodes d'accès aux données des ruchers
abstract class IApiaryRepository {
  /// Récupère tous les ruchers
  Future<List<Apiary>> getApiaries();

  /// Récupère un rucher par son ID
  Future<Apiary?> getApiaryById(String apiaryId);

  /// Récupère toutes les ruches d'un rucher
  Future<List<Hive>> getHivesForApiary(String apiaryId);

  /// Ajoute un nouveau rucher
  Future<String?> addApiary(Apiary apiary);

  /// Met à jour un rucher existant
  Future<bool> updateApiary(String apiaryId, Apiary apiary);

  /// Supprime un rucher
  Future<bool> deleteApiary(String apiaryId);

  /// Ajoute une nouvelle ruche à un rucher
  Future<String?> addHiveToApiary(String apiaryId, Hive hive);

  /// Supprime une ruche d'un rucher
  Future<bool> deleteHiveFromApiary(String apiaryId, String hiveId);
}
