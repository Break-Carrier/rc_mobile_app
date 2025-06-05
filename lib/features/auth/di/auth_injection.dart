import 'package:firebase_auth/firebase_auth.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_auth_state.dart';
import '../domain/usecases/sign_in_with_email_password.dart';
import '../domain/usecases/sign_up_with_email_password.dart';
import '../domain/usecases/sign_out.dart';
import '../presentation/bloc/auth_bloc.dart';

/// Configuration de l'injection de dépendances pour l'authentification
class AuthInjection {
  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthRepository? _authRepository;
  static GetAuthState? _getAuthState;
  static SignInWithEmailPassword? _signInWithEmailPassword;
  static SignUpWithEmailPassword? _signUpWithEmailPassword;
  static SignOut? _signOut;
  static AuthBloc? _authBloc;

  /// Data Source
  static AuthRemoteDataSource getAuthRemoteDataSource() {
    return _authRemoteDataSource ??= AuthRemoteDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
    );
  }

  /// Repository
  static AuthRepository getAuthRepository() {
    return _authRepository ??= AuthRepositoryImpl(
      remoteDataSource: getAuthRemoteDataSource(),
    );
  }

  /// Use Cases
  static GetAuthState getGetAuthStateUseCase() {
    return _getAuthState ??= GetAuthState(getAuthRepository());
  }

  static SignInWithEmailPassword getSignInWithEmailPasswordUseCase() {
    return _signInWithEmailPassword ??=
        SignInWithEmailPassword(getAuthRepository());
  }

  static SignUpWithEmailPassword getSignUpWithEmailPasswordUseCase() {
    return _signUpWithEmailPassword ??=
        SignUpWithEmailPassword(getAuthRepository());
  }

  static SignOut getSignOutUseCase() {
    return _signOut ??= SignOut(getAuthRepository());
  }

  /// BLoC
  static AuthBloc getAuthBloc() {
    return _authBloc ??= AuthBloc(
      getAuthState: getGetAuthStateUseCase(),
      signInWithEmailPassword: getSignInWithEmailPasswordUseCase(),
      signUpWithEmailPassword: getSignUpWithEmailPasswordUseCase(),
      signOut: getSignOutUseCase(),
    );
  }

  /// Nettoie toutes les instances (pour les tests)
  static void reset() {
    _authBloc?.close();
    _authRemoteDataSource = null;
    _authRepository = null;
    _getAuthState = null;
    _signInWithEmailPassword = null;
    _signUpWithEmailPassword = null;
    _signOut = null;
    _authBloc = null;
  }
}
