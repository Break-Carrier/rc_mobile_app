import '../../data/models/hive_model.dart';
import '../entities/hive.dart';
import '../repositories/hive_repository.dart';
import '../../../apiary/domain/repositories/apiary_repository.dart';
import '../../../apiary/domain/usecases/get_current_user_id.dart';

/// Use case pour créer une nouvelle ruche
class CreateHive {
  final HiveRepository _hiveRepository;
  final ApiaryRepository _apiaryRepository;
  final GetCurrentUserId _getCurrentUserId;

  const CreateHive(
    this._hiveRepository,
    this._apiaryRepository,
    this._getCurrentUserId,
  );

  /// Crée une nouvelle ruche dans un rucher
  Future<({Hive? result, Exception? error})> call(
      CreateHiveParams params) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    // Vérifier que le rucher existe et appartient à l'utilisateur
    final apiaryResult = await _apiaryRepository.getApiaryById(params.apiaryId);
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

    // Créer l'entité ruche
    final hive = Hive(
      id: '', // Sera généré par Firebase
      name: params.name,
      apiaryId: params.apiaryId,
      ownerId: userId,
      description: params.description,
      hiveType: params.hiveType,
      material: params.material,
      frameCount: params.frameCount,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // Créer la ruche
    final createResult = await _hiveRepository.createHive(hive);
    if (createResult.error != null) {
      return createResult;
    }

    // Incrémenter le nombre de ruches dans le rucher
    await _apiaryRepository.incrementHiveCount(params.apiaryId);

    return createResult;
  }
}

/// Paramètres pour la création d'une ruche
class CreateHiveParams {
  final String apiaryId;
  final String name;
  final String? description;
  final String? hiveType;
  final String? material;
  final int? frameCount;

  const CreateHiveParams({
    required this.apiaryId,
    required this.name,
    this.description,
    this.hiveType,
    this.material,
    this.frameCount,
  });
}
