import '../entities/apiary.dart';

/// Interface du repository pour les ruchers
///
/// Définit les opérations de persistance des ruchers
/// suivant les principes Clean Architecture
abstract class ApiaryRepository {
  /// Récupère tous les ruchers d'un utilisateur
  Future<({List<Apiary>? result, Exception? error})> getUserApiaries(
      String userId);

  /// Récupère un rucher par son ID
  Future<({Apiary? result, Exception? error})> getApiaryById(String apiaryId);

  /// Crée un nouveau rucher
  Future<({Apiary? result, Exception? error})> createApiary(Apiary apiary);

  /// Met à jour un rucher existant
  Future<({Apiary? result, Exception? error})> updateApiary(Apiary apiary);

  /// Supprime un rucher
  Future<({bool? result, Exception? error})> deleteApiary(String apiaryId);

  /// Incrémente le nombre de ruches d'un rucher
  Future<({bool? result, Exception? error})> incrementHiveCount(
      String apiaryId);

  /// Décrémente le nombre de ruches d'un rucher
  Future<({bool? result, Exception? error})> decrementHiveCount(
      String apiaryId);

  /// Écoute les changements des ruchers d'un utilisateur en temps réel
  Stream<List<Apiary>> watchUserApiaries(String userId);
}
