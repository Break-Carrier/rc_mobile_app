import '../repositories/apiary_repository.dart';
import '../../../hive/domain/repositories/hive_repository.dart';
import 'get_current_user_id.dart';

/// Use case pour synchroniser le nombre de ruches d'un rucher
class SyncHiveCount {
  final ApiaryRepository _apiaryRepository;
  final HiveRepository _hiveRepository;
  final GetCurrentUserId _getCurrentUserId;

  const SyncHiveCount(
    this._apiaryRepository,
    this._hiveRepository,
    this._getCurrentUserId,
  );

  /// Synchronise le nombre de ruches du rucher avec la réalité
  Future<({bool? result, Exception? error})> call(String apiaryId) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    try {
      // Récupérer le rucher pour vérifier la propriété
      final apiaryResult = await _apiaryRepository.getApiaryById(apiaryId);
      if (apiaryResult.error != null) {
        return (result: null, error: apiaryResult.error);
      }

      final apiary = apiaryResult.result;
      if (apiary == null) {
        return (result: null, error: Exception('Rucher non trouvé'));
      }

      if (apiary.ownerId != userId) {
        return (result: null, error: Exception('Accès non autorisé'));
      }

      // Compter le nombre réel de ruches
      final hivesResult = await _hiveRepository.getApiaryHives(apiaryId);
      if (hivesResult.error != null) {
        return (result: null, error: hivesResult.error);
      }

      final realHiveCount = hivesResult.result?.length ?? 0;

      // Mettre à jour le rucher avec le bon nombre
      final updatedApiary = apiary.copyWith(
        hiveCount: realHiveCount,
        updatedAt: DateTime.now(),
      );

      final updateResult = await _apiaryRepository.updateApiary(updatedApiary);
      return (result: updateResult.result != null, error: updateResult.error);
    } catch (e) {
      return (
        result: null,
        error: Exception('Erreur lors de la synchronisation: $e')
      );
    }
  }

  /// Synchronise tous les ruchers d'un utilisateur
  Future<({int? synchronized, Exception? error})> syncAllUserApiaries() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (synchronized: null, error: Exception('Utilisateur non connecté'));
    }

    try {
      // Récupérer tous les ruchers de l'utilisateur
      final apiariesResult = await _apiaryRepository.getUserApiaries(userId);
      if (apiariesResult.error != null) {
        return (synchronized: null, error: apiariesResult.error);
      }

      final apiaries = apiariesResult.result ?? [];
      int synchronizedCount = 0;

      // Synchroniser chaque rucher
      for (final apiary in apiaries) {
        final syncResult = await call(apiary.id);
        if (syncResult.result == true) {
          synchronizedCount++;
        }
      }

      return (synchronized: synchronizedCount, error: null);
    } catch (e) {
      return (
        synchronized: null,
        error: Exception('Erreur lors de la synchronisation globale: $e')
      );
    }
  }
}
