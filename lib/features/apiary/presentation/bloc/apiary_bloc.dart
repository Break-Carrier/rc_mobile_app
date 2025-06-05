import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../domain/usecases/create_apiary.dart';
import '../../domain/usecases/delete_apiary.dart';
import '../../domain/usecases/get_user_apiaries.dart';
import '../../domain/usecases/update_apiary.dart';
import 'apiary_event.dart';
import 'apiary_state.dart';

/// BLoC pour la gestion des ruchers
class ApiaryBloc extends Bloc<ApiaryEvent, ApiaryState> {
  final GetUserApiaries _getUserApiaries;
  final CreateApiary _createApiary;
  final UpdateApiary _updateApiary;
  final DeleteApiary _deleteApiary;
  final Logger _logger;

  StreamSubscription<List<dynamic>>? _apiariesSubscription;

  ApiaryBloc({
    required GetUserApiaries getUserApiaries,
    required CreateApiary createApiary,
    required UpdateApiary updateApiary,
    required DeleteApiary deleteApiary,
    required Logger logger,
  })  : _getUserApiaries = getUserApiaries,
        _createApiary = createApiary,
        _updateApiary = updateApiary,
        _deleteApiary = deleteApiary,
        _logger = logger,
        super(const ApiaryInitial()) {
    // Enregistrement des handlers d'événements
    on<LoadUserApiaries>(_onLoadUserApiaries);
    on<StartWatchingApiaries>(_onStartWatchingApiaries);
    on<StopWatchingApiaries>(_onStopWatchingApiaries);
    on<CreateApiaryRequested>(_onCreateApiaryRequested);
    on<UpdateApiaryRequested>(_onUpdateApiaryRequested);
    on<DeleteApiaryRequested>(_onDeleteApiaryRequested);
    on<RefreshApiaries>(_onRefreshApiaries);
    on<ResetApiaryState>(_onResetApiaryState);
  }

  /// Charge les ruchers de l'utilisateur (une fois)
  Future<void> _onLoadUserApiaries(
    LoadUserApiaries event,
    Emitter<ApiaryState> emit,
  ) async {
    try {
      emit(const ApiaryLoading());
      _logger.d('Chargement des ruchers de l\'utilisateur');

      final result = await _getUserApiaries();

      if (result.error != null) {
        _logger.e('Erreur lors du chargement des ruchers: ${result.error}');
        emit(ApiaryError(result.error!.toString()));
        return;
      }

      final apiaries = result.result ?? [];
      _logger.d('${apiaries.length} ruchers chargés');

      if (apiaries.isEmpty) {
        emit(const ApiaryEmpty());
      } else {
        emit(ApiaryLoaded(apiaries));
      }
    } catch (e, stackTrace) {
      _logger.e('Erreur inattendue lors du chargement',
          error: e, stackTrace: stackTrace);
      emit(ApiaryError('Erreur lors du chargement des ruchers: $e'));
    }
  }

  /// Démarre l'écoute en temps réel des ruchers
  Future<void> _onStartWatchingApiaries(
    StartWatchingApiaries event,
    Emitter<ApiaryState> emit,
  ) async {
    try {
      _logger.d('Démarrage de l\'écoute temps réel des ruchers');

      // Arrêter l'ancien stream s'il existe
      await _apiariesSubscription?.cancel();

      final stream = _getUserApiaries.watchUserApiaries();
      if (stream == null) {
        emit(const ApiaryError('Utilisateur non connecté'));
        return;
      }

      // Émettre un état de chargement initial
      emit(const ApiaryLoading());

      _apiariesSubscription = stream.listen(
        (apiaries) {
          _logger.d('Mise à jour temps réel: ${apiaries.length} ruchers');

          if (apiaries.isEmpty) {
            add(const ResetApiaryState());
            emit(const ApiaryEmpty());
          } else {
            emit(ApiaryLoaded(apiaries, isWatching: true));
          }
        },
        onError: (error) {
          _logger.e('Erreur dans le stream des ruchers: $error');
          emit(ApiaryError('Erreur de connexion: $error'));
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Erreur lors du démarrage de l\'écoute',
          error: e, stackTrace: stackTrace);
      emit(ApiaryError('Erreur lors de l\'écoute des ruchers: $e'));
    }
  }

  /// Arrête l'écoute en temps réel
  Future<void> _onStopWatchingApiaries(
    StopWatchingApiaries event,
    Emitter<ApiaryState> emit,
  ) async {
    _logger.d('Arrêt de l\'écoute temps réel des ruchers');
    await _apiariesSubscription?.cancel();
    _apiariesSubscription = null;

    // Garder les données actuelles mais désactiver l'écoute
    if (state is ApiaryLoaded) {
      final currentState = state as ApiaryLoaded;
      emit(currentState.copyWith(isWatching: false));
    }
  }

  /// Crée un nouveau rucher
  Future<void> _onCreateApiaryRequested(
    CreateApiaryRequested event,
    Emitter<ApiaryState> emit,
  ) async {
    try {
      _logger.d('Création d\'un nouveau rucher: ${event.params.name}');

      final result = await _createApiary(event.params);

      if (result.error != null) {
        _logger.e('Erreur lors de la création: ${result.error}');
        emit(ApiaryError(result.error!.toString()));
        return;
      }

      final newApiary = result.result!;
      _logger.d('Rucher créé avec succès: ${newApiary.id}');

      // Recharger la liste si on n'écoute pas en temps réel
      if (state is ApiaryLoaded && !(state as ApiaryLoaded).isWatching) {
        add(const LoadUserApiaries());
      }
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la création', error: e, stackTrace: stackTrace);
      emit(ApiaryError('Erreur lors de la création du rucher: $e'));
    }
  }

  /// Met à jour un rucher
  Future<void> _onUpdateApiaryRequested(
    UpdateApiaryRequested event,
    Emitter<ApiaryState> emit,
  ) async {
    try {
      _logger.d('Mise à jour du rucher: ${event.params.apiaryId}');

      final result = await _updateApiary(event.params);

      if (result.error != null) {
        _logger.e('Erreur lors de la mise à jour: ${result.error}');
        emit(ApiaryError(result.error!.toString()));
        return;
      }

      _logger.d('Rucher mis à jour avec succès');

      // Recharger la liste si on n'écoute pas en temps réel
      if (state is ApiaryLoaded && !(state as ApiaryLoaded).isWatching) {
        add(const LoadUserApiaries());
      }
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la mise à jour',
          error: e, stackTrace: stackTrace);
      emit(ApiaryError('Erreur lors de la mise à jour du rucher: $e'));
    }
  }

  /// Supprime un rucher
  Future<void> _onDeleteApiaryRequested(
    DeleteApiaryRequested event,
    Emitter<ApiaryState> emit,
  ) async {
    try {
      _logger.d('Suppression du rucher: ${event.apiaryId}');

      final result = await _deleteApiary(event.apiaryId);

      if (result.error != null) {
        _logger.e('Erreur lors de la suppression: ${result.error}');
        emit(ApiaryError(result.error!.toString()));
        return;
      }

      _logger.d('Rucher supprimé avec succès');

      // Recharger la liste si on n'écoute pas en temps réel
      if (state is ApiaryLoaded && !(state as ApiaryLoaded).isWatching) {
        add(const LoadUserApiaries());
      }
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de la suppression',
          error: e, stackTrace: stackTrace);
      emit(ApiaryError('Erreur lors de la suppression du rucher: $e'));
    }
  }

  /// Rafraîchit la liste des ruchers
  Future<void> _onRefreshApiaries(
    RefreshApiaries event,
    Emitter<ApiaryState> emit,
  ) async {
    // Si on écoute en temps réel, pas besoin de refresh manuel
    if (state is ApiaryLoaded && (state as ApiaryLoaded).isWatching) {
      return;
    }

    // Émettre un état de chargement avec les données actuelles
    if (state is ApiaryLoaded) {
      emit(ApiaryLoadingWithData((state as ApiaryLoaded).apiaries));
    }

    add(const LoadUserApiaries());
  }

  /// Remet à zéro l'état du BLoC
  Future<void> _onResetApiaryState(
    ResetApiaryState event,
    Emitter<ApiaryState> emit,
  ) async {
    _logger.d('Remise à zéro de l\'état des ruchers');
    await _apiariesSubscription?.cancel();
    _apiariesSubscription = null;
    emit(const ApiaryInitial());
  }

  @override
  Future<void> close() async {
    _logger.d('Fermeture du ApiaryBloc');
    await _apiariesSubscription?.cancel();
    return super.close();
  }
}
