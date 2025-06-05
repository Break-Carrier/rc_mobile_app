/// Interface de base pour tous les use cases avec gestion d'erreur
abstract class UseCase<Type, Params> {
  Future<({Type? result, Exception? error})> call(Params params);
}

/// Use case sans paramètres
abstract class UseCase0<Type> {
  Future<({Type? result, Exception? error})> call();
}

/// Use case pour les opérations void
abstract class VoidUseCase<Params> {
  Future<Exception?> call(Params params);
}

/// Use case void sans paramètres
abstract class VoidUseCase0 {
  Future<Exception?> call();
}

/// Classe pour représenter l'absence de paramètres
class NoParams {
  const NoParams();
}
 