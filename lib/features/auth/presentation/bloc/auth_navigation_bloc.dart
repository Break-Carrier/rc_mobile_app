import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/navigate_to_auth_info.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';

/// Événements pour la navigation d'authentification
abstract class AuthNavigationEvent extends Equatable {
  const AuthNavigationEvent();

  @override
  List<Object?> get props => [];
}

/// Demande de navigation vers les informations d'authentification
class NavigateToAuthInfoRequested extends AuthNavigationEvent {
  const NavigateToAuthInfoRequested();
}

/// Demande d'affichage du dialogue de déconnexion
class ShowLogoutDialogRequested extends AuthNavigationEvent {
  const ShowLogoutDialogRequested();
}

/// États pour la navigation d'authentification
abstract class AuthNavigationState extends Equatable {
  const AuthNavigationState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthNavigationInitial extends AuthNavigationState {
  const AuthNavigationInitial();
}

/// Navigation en cours
class AuthNavigationLoading extends AuthNavigationState {
  const AuthNavigationLoading();
}

/// Navigation réussie
class AuthNavigationSuccess extends AuthNavigationState {
  final String message;

  const AuthNavigationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

/// Dialogue de déconnexion affiché
class LogoutDialogShown extends AuthNavigationState {
  const LogoutDialogShown();
}

/// Déconnexion confirmée
class LogoutConfirmed extends AuthNavigationState {
  const LogoutConfirmed();
}

/// BLoC pour gérer la navigation d'authentification
///
/// Sépare la logique de navigation de la logique d'authentification
/// pour respecter le principe de responsabilité unique
class AuthNavigationBloc
    extends Bloc<AuthNavigationEvent, AuthNavigationState> {
  final NavigateToAuthInfo _navigateToAuthInfo;
  final ShowLogoutDialog _showLogoutDialog;
  final ShowAuthNotification _showAuthNotification;
  final AuthBloc _authBloc;

  AuthNavigationBloc({
    required NavigateToAuthInfo navigateToAuthInfo,
    required ShowLogoutDialog showLogoutDialog,
    required ShowAuthNotification showAuthNotification,
    required AuthBloc authBloc,
  })  : _navigateToAuthInfo = navigateToAuthInfo,
        _showLogoutDialog = showLogoutDialog,
        _showAuthNotification = showAuthNotification,
        _authBloc = authBloc,
        super(const AuthNavigationInitial()) {
    on<NavigateToAuthInfoRequested>(_onNavigateToAuthInfoRequested);
    on<ShowLogoutDialogRequested>(_onShowLogoutDialogRequested);
  }

  /// Gère la navigation vers les informations d'authentification
  Future<void> _onNavigateToAuthInfoRequested(
    NavigateToAuthInfoRequested event,
    Emitter<AuthNavigationState> emit,
  ) async {
    emit(const AuthNavigationLoading());

    try {
      await _navigateToAuthInfo();
      emit(const AuthNavigationSuccess(
        message: 'Navigation vers les informations d\'authentification',
      ));
    } catch (e) {
      _showAuthNotification.showError(
        'Erreur lors de la navigation: ${e.toString()}',
      );
      emit(const AuthNavigationInitial());
    }
  }

  /// Gère l'affichage du dialogue de déconnexion
  Future<void> _onShowLogoutDialogRequested(
    ShowLogoutDialogRequested event,
    Emitter<AuthNavigationState> emit,
  ) async {
    emit(const LogoutDialogShown());

    try {
      final confirmed = await _showLogoutDialog();

      if (confirmed) {
        emit(const LogoutConfirmed());
        // Déclencher la déconnexion via l'AuthBloc
        _authBloc.add(const SignOutRequested());
        _showAuthNotification.showSuccess('Déconnexion en cours...');
      } else {
        emit(const AuthNavigationInitial());
      }
    } catch (e) {
      _showAuthNotification.showError(
        'Erreur lors de l\'affichage du dialogue: ${e.toString()}',
      );
      emit(const AuthNavigationInitial());
    }
  }
}
