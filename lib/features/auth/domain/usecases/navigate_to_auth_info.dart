import 'package:flutter/material.dart';
import '../../../../core/navigation/navigation_service.dart';

/// Use case pour naviguer vers la page d'informations d'authentification
///
/// Suit les principes Clean Architecture en encapsulant
/// la logique de navigation dans un use case
class NavigateToAuthInfo {
  final NavigationService _navigationService;

  const NavigateToAuthInfo(this._navigationService);

  /// Exécute la navigation vers la page d'informations d'authentification
  Future<void> call() async {
    await _navigationService.navigateTo(AppRoutes.authInfo);
  }
}

/// Use case pour afficher une boîte de dialogue de déconnexion
class ShowLogoutDialog {
  final NavigationService _navigationService;

  const ShowLogoutDialog(this._navigationService);

  /// Affiche la boîte de dialogue de confirmation de déconnexion
  ///
  /// Retourne true si l'utilisateur confirme, false sinon
  Future<bool> call() async {
    final result = await _navigationService.showDialogModal<bool>(
      _LogoutConfirmationDialog(),
    );

    return result ?? false;
  }
}

/// Widget de dialogue de confirmation de déconnexion
///
/// Séparé pour respecter la séparation des responsabilités
class _LogoutConfirmationDialog extends StatelessWidget {
  const _LogoutConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Déconnexion'),
      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Déconnecter'),
        ),
      ],
    );
  }
}

/// Use case pour afficher des messages de notification
class ShowAuthNotification {
  final NavigationService _navigationService;

  const ShowAuthNotification(this._navigationService);

  /// Affiche un message de succès d'authentification
  void showSuccess(String message) {
    _navigationService.showSnackBar(message, isError: false);
  }

  /// Affiche un message d'erreur d'authentification
  void showError(String message) {
    _navigationService.showSnackBar(message, isError: true);
  }
}
