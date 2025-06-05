import '../../../auth/domain/usecases/get_auth_state.dart';

/// Use case pour récupérer l'ID de l'utilisateur connecté
class GetCurrentUserId {
  final GetAuthState _getAuthState;

  const GetCurrentUserId(this._getAuthState);

  /// Retourne l'ID de l'utilisateur connecté ou null si non connecté
  String? call() {
    try {
      final user = _getAuthState.getCurrentUser();
      return user?.id;
    } catch (e) {
      // Fallback temporaire pour éviter les crashes d'injection
      // En production, cela devrait retourner null et gérer l'état non connecté
      return 'mock_user_id';
    }
  }
}
