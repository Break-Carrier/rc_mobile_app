import '../entities/hive.dart';
import '../repositories/hive_repository.dart';
import '../../../apiary/domain/repositories/apiary_repository.dart';
import '../../../apiary/domain/usecases/get_current_user_id.dart';

/// Use case pour récupérer les ruches d'un rucher
class GetApiaryHives {
  final HiveRepository _hiveRepository;
  final ApiaryRepository _apiaryRepository;
  final GetCurrentUserId _getCurrentUserId;

  const GetApiaryHives(
    this._hiveRepository,
    this._apiaryRepository,
    this._getCurrentUserId,
  );

  /// Récupère toutes les ruches d'un rucher
  Future<({List<Hive>? result, Exception? error})> call(String apiaryId) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    // Vérifier que le rucher existe et appartient à l'utilisateur
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

    // Récupérer les ruches du rucher
    return await _hiveRepository.getApiaryHives(apiaryId);
  }

  /// Stream des ruches d'un rucher (temps réel)
  Stream<List<Hive>>? watchApiaryHives(String apiaryId) {
    final userId = _getCurrentUserId();
    if (userId == null) return null;

    return _hiveRepository.watchApiaryHives(apiaryId);
  }
}
