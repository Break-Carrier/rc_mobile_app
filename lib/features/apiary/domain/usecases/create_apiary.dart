import '../entities/apiary.dart';
import '../repositories/apiary_repository.dart';
import 'get_current_user_id.dart';

/// Use case pour créer un nouveau rucher
class CreateApiary {
  final ApiaryRepository _repository;
  final GetCurrentUserId _getCurrentUserId;

  const CreateApiary(this._repository, this._getCurrentUserId);

  /// Crée un nouveau rucher pour l'utilisateur connecté
  Future<({Apiary? result, Exception? error})> call(
      CreateApiaryParams params) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _getCurrentUserId();
    if (userId == null) {
      return (result: null, error: Exception('Utilisateur non connecté'));
    }

    // Créer l'entité rucher avec l'ID utilisateur
    final apiary = Apiary(
      id: '', // Sera généré par Firebase
      name: params.name,
      location: params.location,
      description: params.description,
      ownerId: userId,
      latitude: params.latitude,
      longitude: params.longitude,
      hiveCount: 0,
      createdAt: DateTime.now(),
    );

    return await _repository.createApiary(apiary);
  }
}

/// Paramètres pour la création d'un rucher
class CreateApiaryParams {
  final String name;
  final String location;
  final String description;
  final double? latitude;
  final double? longitude;

  const CreateApiaryParams({
    required this.name,
    required this.location,
    required this.description,
    this.latitude,
    this.longitude,
  });
}
