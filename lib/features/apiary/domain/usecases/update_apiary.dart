import '../entities/apiary.dart';
import '../repositories/apiary_repository.dart';
import 'get_current_user_id.dart';

/// Use case pour mettre à jour un rucher
class UpdateApiary {
  final ApiaryRepository _repository;
  final GetCurrentUserId _getCurrentUserId;

  const UpdateApiary(this._repository, this._getCurrentUserId);

  /// Met à jour un rucher existant
  Future<({Apiary? result, Exception? error})> call(
      UpdateApiaryParams params) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    // Récupérer le rucher existant pour vérifier la propriété
    final existingResult = await _repository.getApiaryById(params.apiaryId);
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

    // Créer le rucher mis à jour
    final updatedApiary = existingApiary.copyWith(
      name: params.name,
      location: params.location,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
      updatedAt: DateTime.now(),
    );

    return await _repository.updateApiary(updatedApiary);
  }
}

/// Paramètres pour la mise à jour d'un rucher
class UpdateApiaryParams {
  final String apiaryId;
  final String? name;
  final String? location;
  final String? description;
  final double? latitude;
  final double? longitude;

  const UpdateApiaryParams({
    required this.apiaryId,
    this.name,
    this.location,
    this.description,
    this.latitude,
    this.longitude,
  });
}
