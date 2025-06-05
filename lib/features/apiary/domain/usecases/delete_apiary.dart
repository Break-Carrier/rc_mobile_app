import '../repositories/apiary_repository.dart';
import 'get_current_user_id.dart';

/// Use case pour supprimer un rucher
class DeleteApiary {
  final ApiaryRepository _repository;
  final GetCurrentUserId _getCurrentUserId;

  const DeleteApiary(this._repository, this._getCurrentUserId);

  /// Supprime un rucher existant
  Future<({bool? result, Exception? error})> call(String apiaryId) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    // Récupérer le rucher existant pour vérifier la propriété
    final existingResult = await _repository.getApiaryById(apiaryId);
    if (existingResult.error != null) {
      return (result: null, error: existingResult.error);
    }

    final existingApiary = existingResult.result;
    if (existingApiary == null) {
      return (result: null, error: Exception('Rucher non trouvé'));
    }

    // Vérifier que l'utilisateur est propriétaire du rucher
    if (existingApiary.ownerId != userId) {
      return (result: null, error: Exception('Accès non autorisé'));
    }

    // Vérifier que le rucher n'a pas de ruches
    if (existingApiary.hiveCount > 0) {
      return (
        result: null,
        error:
            Exception('Impossible de supprimer un rucher contenant des ruches')
      );
    }

    return await _repository.deleteApiary(apiaryId);
  }
}
