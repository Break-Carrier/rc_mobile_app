import '../entities/hive.dart';
import '../repositories/hive_repository.dart';
import '../../../apiary/domain/usecases/get_current_user_id.dart';

/// Use case pour récupérer toutes les ruches d'un utilisateur
class GetAllUserHives {
  final HiveRepository _hiveRepository;
  final GetCurrentUserId _getCurrentUserId;

  GetAllUserHives(this._hiveRepository, this._getCurrentUserId);

  /// Récupère toutes les ruches de l'utilisateur actuel
  ///
  /// Retourne:
  /// - Un record avec la liste des ruches et l'erreur éventuelle
  Future<({List<Hive>? result, Exception? error})> call() async {
    try {
      // Récupérer l'ID de l'utilisateur actuel
      final userId = _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        return (result: null, error: Exception('Utilisateur non connecté'));
      }

      // Récupérer toutes les ruches de l'utilisateur
      return await _hiveRepository.getUserHives(userId);
    } catch (e) {
      return (
        result: null,
        error: Exception('Erreur lors de la récupération des ruches: $e')
      );
    }
  }
}
