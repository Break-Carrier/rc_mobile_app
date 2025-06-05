import 'package:flutter/material.dart';

/// Service de navigation suivant les principes Clean Architecture
///
/// Centralise la logique de navigation et découple les widgets
/// de la logique de routage spécifique
abstract class NavigationService {
  /// Navigue vers une page donnée
  Future<T?> navigateTo<T>(String routeName, {Object? arguments});

  /// Navigue vers une page et remplace la pile de navigation
  Future<T?> navigateAndReplace<T>(String routeName, {Object? arguments});

  /// Navigue vers une page et supprime toutes les pages précédentes
  Future<T?> navigateAndClearStack<T>(String routeName, {Object? arguments});

  /// Retourne à la page précédente
  void goBack<T>([T? result]);

  /// Retourne à la page précédente jusqu'à une condition
  void goBackUntil(bool Function(Route<dynamic>) predicate);

  /// Affiche une boîte de dialogue
  Future<T?> showDialogModal<T>(Widget dialog);

  /// Affiche un bottom sheet
  Future<T?> showBottomSheetModal<T>(Widget bottomSheet);

  /// Affiche un snackbar
  void showSnackBar(String message, {bool isError = false});
}

/// Implémentation concrète du service de navigation
class NavigationServiceImpl implements NavigationService {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  /// Clé globale du navigateur pour accès depuis n'importe où
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// Context actuel du navigateur
  BuildContext? get _context => _navigatorKey.currentContext;

  @override
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    if (_context == null) return null;

    return Navigator.of(_context!).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  @override
  Future<T?> navigateAndReplace<T>(String routeName,
      {Object? arguments}) async {
    if (_context == null) return null;

    return Navigator.of(_context!).pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  @override
  Future<T?> navigateAndClearStack<T>(String routeName,
      {Object? arguments}) async {
    if (_context == null) return null;

    return Navigator.of(_context!).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  @override
  void goBack<T>([T? result]) {
    if (_context == null) return;

    Navigator.of(_context!).pop<T>(result);
  }

  @override
  void goBackUntil(bool Function(Route<dynamic>) predicate) {
    if (_context == null) return;

    Navigator.of(_context!).popUntil(predicate);
  }

  @override
  Future<T?> showDialogModal<T>(Widget dialog) async {
    if (_context == null) return null;

    return showDialog<T>(
      context: _context!,
      builder: (context) => dialog,
    );
  }

  @override
  Future<T?> showBottomSheetModal<T>(Widget bottomSheet) async {
    if (_context == null) return null;

    return showModalBottomSheet<T>(
      context: _context!,
      builder: (context) => bottomSheet,
    );
  }

  @override
  void showSnackBar(String message, {bool isError = false}) {
    if (_context == null) return;

    final messenger = ScaffoldMessenger.of(_context!);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Routes de l'application
class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String authInfo = '/auth-info';
  static const String apiaries = '/apiaries';
  static const String hives = '/hives';
  static const String settings = '/settings';

  /// Map des routes vers les widgets
  static Map<String, WidgetBuilder> get routes => {
        // Les routes seront définies dans le router principal
      };
}
