import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/auth_failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_auth_state.dart';
import '../../domain/usecases/sign_in_with_email_password.dart';
import '../../domain/usecases/sign_up_with_email_password.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC pour la gestion de l'authentification
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthState _getAuthState;
  final SignInWithEmailPassword _signInWithEmailPassword;
  final SignUpWithEmailPassword _signUpWithEmailPassword;
  final SignOut _signOut;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required GetAuthState getAuthState,
    required SignInWithEmailPassword signInWithEmailPassword,
    required SignUpWithEmailPassword signUpWithEmailPassword,
    required SignOut signOut,
  })  : _getAuthState = getAuthState,
        _signInWithEmailPassword = signInWithEmailPassword,
        _signUpWithEmailPassword = signUpWithEmailPassword,
        _signOut = signOut,
        super(const AuthInitial()) {
    // Enregistrement des handlers d'événements
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    // Démarrer l'écoute de l'état d'authentification
    _startAuthStateListener();
  }

  /// Démarre l'écoute de l'état d'authentification
  void _startAuthStateListener() {
    _authStateSubscription = _getAuthState().listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Vérifie l'état d'authentification actuel
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _getAuthState.getCurrentUser();
    if (currentUser != null) {
      emit(AuthAuthenticated(user: currentUser));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Gère la connexion avec email et mot de passe
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signInWithEmailPassword(
      SignInParams(email: event.email, password: event.password),
    );

    if (result.error != null) {
      emit(AuthError(failure: result.error! as AuthFailure));
    }
    // Le succès sera géré par l'écoute du stream authStateChanges
  }

  /// Gère l'inscription avec email et mot de passe
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signUpWithEmailPassword(
      SignUpParams(email: event.email, password: event.password),
    );

    if (result.error != null) {
      emit(AuthError(failure: result.error! as AuthFailure));
    }
    // Le succès sera géré par l'écoute du stream authStateChanges
  }

  /// Gère la déconnexion
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final error = await _signOut();

    if (error != null) {
      emit(AuthError(failure: error as AuthFailure));
    }
    // Le succès sera géré par l'écoute du stream authStateChanges
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
