import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';
import '../../../../core/error/app_error.dart';

/// Use case pour récupérer le profil complet d'un utilisateur
///
/// Encapsule la logique métier pour récupérer un profil utilisateur
/// en validant les paramètres d'entrée et en gérant les erreurs.
class GetUserProfile {
  final UserProfileRepository _repository;

  const GetUserProfile(this._repository);

  /// Récupère le profil d'un utilisateur par son ID
  ///
  /// [userId] - Identifiant unique de l'utilisateur (Firebase UID)
  ///
  /// Valide l'ID utilisateur et retourne le profil ou une erreur
  Future<UserProfileResult<UserProfileEntity>> call(String userId) async {
    // Validation des paramètres d'entrée
    final validationError = _validateUserId(userId);
    if (validationError != null) {
      return UserProfileFailure(validationError);
    }

    try {
      // Appel au repository pour récupérer le profil
      final result = await _repository.getUserProfile(userId);

      return result;
    } catch (error) {
      // Gestion des erreurs non prévues
      final appError = ErrorHandler.handleError(error);
      return UserProfileFailure(appError);
    }
  }

  /// Valide l'ID utilisateur
  ValidationError? _validateUserId(String userId) {
    if (userId.isEmpty) {
      return const ValidationError(
        message: 'L\'identifiant utilisateur ne peut pas être vide',
        code: 'EMPTY_USER_ID',
      );
    }

    if (userId.length < 10) {
      return const ValidationError(
        message: 'L\'identifiant utilisateur n\'est pas valide',
        code: 'INVALID_USER_ID',
      );
    }

    return null;
  }
}
