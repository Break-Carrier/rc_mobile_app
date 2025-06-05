import '../entities/hive.dart';

/// Interface du repository pour les ruches
///
/// Définit les opérations de persistance des ruches
/// suivant les principes Clean Architecture
abstract class HiveRepository {
  /// Récupère toutes les ruches d'un rucher
  Future<({List<Hive>? result, Exception? error})> getApiaryHives(
      String apiaryId);

  /// Récupère toutes les ruches d'un utilisateur (tous ruchers confondus)
  Future<({List<Hive>? result, Exception? error})> getUserHives(String userId);

  /// Récupère une ruche par son ID
  Future<({Hive? result, Exception? error})> getHiveById(String hiveId);

  /// Crée une nouvelle ruche
  Future<({Hive? result, Exception? error})> createHive(Hive hive);

  /// Met à jour une ruche existante
  Future<({Hive? result, Exception? error})> updateHive(Hive hive);

  /// Supprime une ruche
  Future<({bool? result, Exception? error})> deleteHive(String hiveId);

  /// Met à jour la date de dernière inspection
  Future<({bool? result, Exception? error})> updateLastInspection(
      String hiveId, DateTime inspectionDate);

  /// Active/désactive une ruche
  Future<({bool? result, Exception? error})> toggleHiveStatus(
      String hiveId, bool isActive);

  /// Écoute les changements des ruches d'un rucher en temps réel
  Stream<List<Hive>> watchApiaryHives(String apiaryId);

  /// Écoute les changements de toutes les ruches d'un utilisateur
  Stream<List<Hive>> watchUserHives(String userId);
}
