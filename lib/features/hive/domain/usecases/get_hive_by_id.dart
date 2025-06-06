import '../entities/hive.dart';
import '../repositories/hive_repository.dart';

/// Use case pour récupérer une ruche par son ID
class GetHiveById {
  final HiveRepository _hiveRepository;

  const GetHiveById(this._hiveRepository);

  /// Récupère une ruche par son ID
  ///
  /// Paramètres:
  /// - [hiveId] : ID de la ruche à récupérer
  ///
  /// Retourne:
  /// - Un record avec le résultat et l'erreur éventuelle
  Future<({Hive? result, Exception? error})> call(String hiveId) async {
    try {
      if (hiveId.isEmpty) {
        return (
          result: null,
          error: Exception('L\'ID de la ruche ne peut pas être vide')
        );
      }

      return await _hiveRepository.getHiveById(hiveId);
    } catch (e) {
      return (
        result: null,
        error: Exception('Erreur lors de la récupération de la ruche: $e')
      );
    }
  }
}
