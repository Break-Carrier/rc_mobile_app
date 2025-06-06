import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/repositories/user_profile_repository.dart';
import '../data/repositories/user_profile_repository_impl.dart';

/// Configuration de l'injection de dépendances pour UserProfile
class UserProfileInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Enregistre toutes les dépendances UserProfile dans GetIt
  static void setupUserProfileDependencies() {
    // Repository
    if (!_getIt.isRegistered<UserProfileRepository>()) {
      _getIt.registerLazySingleton<UserProfileRepository>(
        () => UserProfileRepositoryImpl(
          firestore: FirebaseFirestore.instance,
        ),
      );
    }
  }

  /// Récupère une instance du repository UserProfile
  static UserProfileRepository getUserProfileRepository() =>
      _getIt<UserProfileRepository>();

  /// Supprime toutes les dépendances UserProfile (pour les tests)
  static void resetUserProfileDependencies() {
    if (_getIt.isRegistered<UserProfileRepository>()) {
      _getIt.unregister<UserProfileRepository>();
    }
  }
}
