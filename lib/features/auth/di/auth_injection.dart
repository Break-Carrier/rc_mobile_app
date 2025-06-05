import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/navigation/navigation_service.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_auth_state.dart';
import '../domain/usecases/sign_in_with_email_password.dart';
import '../domain/usecases/sign_up_with_email_password.dart';
import '../domain/usecases/sign_out.dart';
import '../domain/usecases/navigate_to_auth_info.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../presentation/bloc/auth_navigation_bloc.dart';

/// Configuration de l'injection de dépendances pour l'authentification
class AuthInjection {
  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthRepository? _authRepository;
  static NavigationService? _navigationService;
  static GetAuthState? _getAuthState;
  static SignInWithEmailPassword? _signInWithEmailPassword;
  static SignUpWithEmailPassword? _signUpWithEmailPassword;
  static SignOut? _signOut;
  static NavigateToAuthInfo? _navigateToAuthInfo;
  static ShowLogoutDialog? _showLogoutDialog;
  static ShowAuthNotification? _showAuthNotification;
  static AuthBloc? _authBloc;
  static AuthNavigationBloc? _authNavigationBloc;

  /// Navigation Service
  static NavigationService getNavigationService() {
    return _navigationService ??= NavigationServiceImpl();
  }

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

  /// Use Cases - Authentication
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

  /// Use Cases - Navigation
  static NavigateToAuthInfo getNavigateToAuthInfoUseCase() {
    return _navigateToAuthInfo ??= NavigateToAuthInfo(getNavigationService());
  }

  static ShowLogoutDialog getShowLogoutDialogUseCase() {
    return _showLogoutDialog ??= ShowLogoutDialog(getNavigationService());
  }

  static ShowAuthNotification getShowAuthNotificationUseCase() {
    return _showAuthNotification ??=
        ShowAuthNotification(getNavigationService());
  }

  /// BLoCs
  static AuthBloc getAuthBloc() {
    return _authBloc ??= AuthBloc(
      getAuthState: getGetAuthStateUseCase(),
      signInWithEmailPassword: getSignInWithEmailPasswordUseCase(),
      signUpWithEmailPassword: getSignUpWithEmailPasswordUseCase(),
      signOut: getSignOutUseCase(),
    );
  }

  static AuthNavigationBloc getAuthNavigationBloc() {
    return _authNavigationBloc ??= AuthNavigationBloc(
      navigateToAuthInfo: getNavigateToAuthInfoUseCase(),
      showLogoutDialog: getShowLogoutDialogUseCase(),
      showAuthNotification: getShowAuthNotificationUseCase(),
      authBloc: getAuthBloc(),
    );
  }

  /// Nettoie toutes les instances (pour les tests)
  static void reset() {
    _authBloc?.close();
    _authNavigationBloc?.close();
    _authRemoteDataSource = null;
    _authRepository = null;
    _navigationService = null;
    _getAuthState = null;
    _signInWithEmailPassword = null;
    _signUpWithEmailPassword = null;
    _signOut = null;
    _navigateToAuthInfo = null;
    _showLogoutDialog = null;
    _showAuthNotification = null;
    _authBloc = null;
    _authNavigationBloc = null;
  }
}
