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
      // Retourner null quand l'utilisateur n'est pas connecté
      // permet à ApiaryBloc d'émettre une erreur explicite
      return null;
    }
  }
}
