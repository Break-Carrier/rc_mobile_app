import '../repositories/hive_repository.dart';
import '../../../apiary/domain/repositories/apiary_repository.dart';
import '../../../apiary/domain/usecases/get_current_user_id.dart';

/// Use case pour supprimer une ruche
class DeleteHive {
  final HiveRepository _hiveRepository;
  final ApiaryRepository _apiaryRepository;
  final GetCurrentUserId _getCurrentUserId;

  const DeleteHive(
    this._hiveRepository,
    this._apiaryRepository,
    this._getCurrentUserId,
  );

  /// Supprime une ruche existante
  Future<({bool? result, Exception? error})> call(String hiveId) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    // Récupérer la ruche pour vérifier la propriété
    final hiveResult = await _hiveRepository.getHiveById(hiveId);
    if (hiveResult.error != null) {
      return (result: null, error: hiveResult.error);
    }

    final hive = hiveResult.result;
    if (hive == null) {
      return (result: null, error: Exception('Ruche non trouvée'));
    }

    // Vérifier que l'utilisateur est propriétaire de la ruche
    if (hive.ownerId != userId) {
      return (result: null, error: Exception('Accès non autorisé'));
    }

    // Supprimer la ruche
    final deleteResult = await _hiveRepository.deleteHive(hiveId);
    if (deleteResult.error != null) {
      return deleteResult;
    }

    // Décrémenter le nombre de ruches dans le rucher
    await _apiaryRepository.decrementHiveCount(hive.apiaryId);

    return deleteResult;
  }
}
