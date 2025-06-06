import 'package:equatable/equatable.dart';

import '../../domain/usecases/create_apiary.dart';
import '../../domain/usecases/update_apiary.dart';

/// Événements du BLoC Ruchers
abstract class ApiaryEvent extends Equatable {
  const ApiaryEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour charger les ruchers de l'utilisateur
class LoadUserApiaries extends ApiaryEvent {
  const LoadUserApiaries();
}

/// Événement pour démarrer l'écoute en temps réel des ruchers
class StartWatchingApiaries extends ApiaryEvent {
  const StartWatchingApiaries();
}

/// Événement pour arrêter l'écoute en temps réel des ruchers
class StopWatchingApiaries extends ApiaryEvent {
  const StopWatchingApiaries();
}

/// Événement pour créer un nouveau rucher
class CreateApiaryRequested extends ApiaryEvent {
  final CreateApiaryParams params;

  const CreateApiaryRequested(this.params);

  @override
  List<Object?> get props => [params];
}

/// Événement pour mettre à jour un rucher
class UpdateApiaryRequested extends ApiaryEvent {
  final UpdateApiaryParams params;

  const UpdateApiaryRequested(this.params);

  @override
  List<Object?> get props => [params];
}

/// Événement pour supprimer un rucher
class DeleteApiaryRequested extends ApiaryEvent {
  final String apiaryId;

  const DeleteApiaryRequested(this.apiaryId);

  @override
  List<Object?> get props => [apiaryId];
}

/// Événement pour rafraîchir la liste des ruchers
class RefreshApiaries extends ApiaryEvent {
  const RefreshApiaries();
}

/// Événement pour réinitialiser l'état du BLoC
class ResetApiaryState extends ApiaryEvent {
  const ResetApiaryState();
}

/// Événement interne pour les mises à jour du stream (ne pas utiliser directement)
class ApiariesStreamUpdated extends ApiaryEvent {
  final List<dynamic> apiaries;
  final bool isWatching;

  const ApiariesStreamUpdated(this.apiaries, {this.isWatching = true});

  @override
  List<Object?> get props => [apiaries, isWatching];
}

/// Événement interne pour les erreurs du stream (ne pas utiliser directement)
class ApiariesStreamError extends ApiaryEvent {
  final String error;

  const ApiariesStreamError(this.error);

  @override
  List<Object?> get props => [error];
}
