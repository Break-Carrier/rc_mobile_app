import 'package:equatable/equatable.dart';

import '../../domain/entities/apiary.dart';

/// États du BLoC Ruchers
abstract class ApiaryState extends Equatable {
  const ApiaryState();

  @override
  List<Object?> get props => [];
}

/// État initial
class ApiaryInitial extends ApiaryState {
  const ApiaryInitial();
}

/// État de chargement
class ApiaryLoading extends ApiaryState {
  const ApiaryLoading();
}

/// État de chargement avec données (pour le refresh)
class ApiaryLoadingWithData extends ApiaryState {
  final List<Apiary> apiaries;

  const ApiaryLoadingWithData(this.apiaries);

  @override
  List<Object?> get props => [apiaries];
}

/// État de succès avec liste des ruchers
class ApiaryLoaded extends ApiaryState {
  final List<Apiary> apiaries;
  final bool isWatching; // Indique si l'écoute temps réel est active

  const ApiaryLoaded(this.apiaries, {this.isWatching = false});

  @override
  List<Object?> get props => [apiaries, isWatching];

  /// Copie l'état avec de nouvelles données
  ApiaryLoaded copyWith({
    List<Apiary>? apiaries,
    bool? isWatching,
  }) {
    return ApiaryLoaded(
      apiaries ?? this.apiaries,
      isWatching: isWatching ?? this.isWatching,
    );
  }
}

/// État d'erreur
class ApiaryError extends ApiaryState {
  final String message;
  final List<Apiary>? apiaries; // Garde les données existantes en cas d'erreur

  const ApiaryError(this.message, {this.apiaries});

  @override
  List<Object?> get props => [message, apiaries];
}

/// État de succès après création d'un rucher
class ApiaryCreated extends ApiaryState {
  final Apiary apiary;
  final List<Apiary> allApiaries;

  const ApiaryCreated(this.apiary, this.allApiaries);

  @override
  List<Object?> get props => [apiary, allApiaries];
}

/// État de succès après mise à jour d'un rucher
class ApiaryUpdated extends ApiaryState {
  final Apiary apiary;
  final List<Apiary> allApiaries;

  const ApiaryUpdated(this.apiary, this.allApiaries);

  @override
  List<Object?> get props => [apiary, allApiaries];
}

/// État de succès après suppression d'un rucher
class ApiaryDeleted extends ApiaryState {
  final String deletedApiaryId;
  final List<Apiary> allApiaries;

  const ApiaryDeleted(this.deletedApiaryId, this.allApiaries);

  @override
  List<Object?> get props => [deletedApiaryId, allApiaries];
}

/// État quand aucun rucher n'est trouvé
class ApiaryEmpty extends ApiaryState {
  const ApiaryEmpty();
}
