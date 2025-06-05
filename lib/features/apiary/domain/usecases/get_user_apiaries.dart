import '../entities/apiary.dart';
import '../repositories/apiary_repository.dart';
import 'get_current_user_id.dart';

/// Use case pour récupérer les ruchers de l'utilisateur connecté
class GetUserApiaries {
  final ApiaryRepository _repository;
  final GetCurrentUserId _getCurrentUserId;

  const GetUserApiaries(this._repository, this._getCurrentUserId);

  /// Récupère tous les ruchers de l'utilisateur connecté
  Future<({List<Apiary>? result, Exception? error})> call() async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    return await _repository.getUserApiaries(userId);
  }

  /// Stream des ruchers de l'utilisateur connecté (temps réel)
  Stream<List<Apiary>>? watchUserApiaries() {
    final userId = _getCurrentUserId();
    if (userId == null) return null;

    return _repository.watchUserApiaries(userId);
  }
}
