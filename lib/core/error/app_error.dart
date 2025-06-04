import 'package:equatable/equatable.dart';

/// Classe de base pour toutes les erreurs de l'application
abstract class AppError extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];
}

/// Erreur de connexion réseau
class NetworkError extends AppError {
  const NetworkError({
    super.message = 'Erreur de connexion réseau',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Erreur de timeout
class TimeoutError extends AppError {
  const TimeoutError({
    super.message = 'Délai d\'attente dépassé',
    super.code = 'TIMEOUT_ERROR',
    super.originalError,
  });
}

/// Erreur de données non trouvées
class DataNotFoundError extends AppError {
  const DataNotFoundError({
    super.message = 'Données non trouvées',
    super.code = 'DATA_NOT_FOUND',
    super.originalError,
  });
}

/// Erreur de validation
class ValidationError extends AppError {
  const ValidationError({
    super.message = 'Données invalides',
    super.code = 'VALIDATION_ERROR',
    super.originalError,
  });
}

/// Erreur de Firebase
class FirebaseError extends AppError {
  const FirebaseError({
    super.message = 'Erreur Firebase',
    super.code = 'FIREBASE_ERROR',
    super.originalError,
  });
}

/// Erreur de service
class ServiceError extends AppError {
  const ServiceError({
    super.message = 'Erreur de service',
    super.code = 'SERVICE_ERROR',
    super.originalError,
  });
}

/// Erreur générique
class UnknownError extends AppError {
  const UnknownError({
    super.message = 'Erreur inconnue',
    super.code = 'UNKNOWN_ERROR',
    super.originalError,
  });
}

/// Handler centralisé pour la gestion des erreurs
class ErrorHandler {
  /// Convertit une exception en AppError
  static AppError handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    // Gestion des erreurs spécifiques
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return NetworkError(originalError: error);
    }

    if (errorString.contains('timeout')) {
      return const TimeoutError();
    }

    if (errorString.contains('not found')) {
      return DataNotFoundError(originalError: error);
    }

    if (errorString.contains('firebase')) {
      return FirebaseError(originalError: error);
    }

    return UnknownError(
      message: error.toString(),
      originalError: error,
    );
  }

  /// Obtient un message d'erreur user-friendly
  static String getUserMessage(AppError error) {
    return switch (error) {
      NetworkError _ => 'Vérifiez votre connexion internet et réessayez.',
      TimeoutError _ => 'La requête a pris trop de temps. Veuillez réessayer.',
      DataNotFoundError _ => 'Les données demandées sont introuvables.',
      ValidationError _ => 'Les données saisies ne sont pas valides.',
      FirebaseError _ => 'Erreur de connexion au serveur. Réessayez plus tard.',
      _ => error.message,
    };
  }
}
