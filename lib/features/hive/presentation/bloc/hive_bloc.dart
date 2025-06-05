import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../domain/usecases/create_hive.dart';
import '../../domain/usecases/delete_hive.dart';
import '../../domain/usecases/get_apiary_hives.dart';
import 'hive_event.dart';
import 'hive_state.dart';

/// BLoC pour la gestion des ruches
class HiveBloc extends Bloc<HiveEvent, HiveState> {
  final GetApiaryHives _getApiaryHives;
  final CreateHive _createHive;
  final DeleteHive _deleteHive;
  final Logger _logger;

  HiveBloc({
    required GetApiaryHives getApiaryHives,
    required CreateHive createHive,
    required DeleteHive deleteHive,
    required Logger logger,
  })  : _getApiaryHives = getApiaryHives,
        _createHive = createHive,
        _deleteHive = deleteHive,
        _logger = logger,
        super(HiveInitial()) {
    on<LoadApiaryHives>(_onLoadApiaryHives);
    on<CreateHiveRequested>(_onCreateHiveRequested);
    on<DeleteHiveRequested>(_onDeleteHiveRequested);
    on<RefreshHives>(_onRefreshHives);
  }

  Future<void> _onLoadApiaryHives(
    LoadApiaryHives event,
    Emitter<HiveState> emit,
  ) async {
    if (state is! HiveLoaded) {
      emit(HiveLoading());
    }

    try {
      final result = await _getApiaryHives(event.apiaryId);

      if (result.error != null) {
        _logger.e('Erreur lors du chargement des ruches: ${result.error}');
        emit(HiveError(result.error.toString()));
      } else if (result.result != null) {
        _logger.d('Ruches chargées: ${result.result!.length}');
        emit(HiveLoaded(result.result!));
      } else {
        emit(HiveError('Aucune donnée reçue'));
      }
    } catch (e) {
      _logger.e('Erreur inattendue lors du chargement des ruches: $e');
      emit(HiveError('Erreur inattendue: $e'));
    }
  }

  Future<void> _onCreateHiveRequested(
    CreateHiveRequested event,
    Emitter<HiveState> emit,
  ) async {
    try {
      final result = await _createHive(event.params);

      if (result.error != null) {
        _logger.e('Erreur lors de la création de la ruche: ${result.error}');
        emit(HiveError(result.error.toString()));
      } else if (result.result != null) {
        _logger.d('Ruche créée: ${result.result!.name}');
        // Recharger les ruches du rucher
        add(LoadApiaryHives(event.params.apiaryId));
      } else {
        emit(HiveError('Erreur lors de la création'));
      }
    } catch (e) {
      _logger.e('Erreur inattendue lors de la création de la ruche: $e');
      emit(HiveError('Erreur inattendue: $e'));
    }
  }

  Future<void> _onDeleteHiveRequested(
    DeleteHiveRequested event,
    Emitter<HiveState> emit,
  ) async {
    try {
      final result = await _deleteHive(event.hiveId);

      if (result.error != null) {
        _logger.e('Erreur lors de la suppression de la ruche: ${result.error}');
        emit(HiveError(result.error.toString()));
      } else {
        _logger.d('Ruche supprimée: ${event.hiveId}');
        // Recharger automatiquement si on a l'état loaded
        if (state is HiveLoaded) {
          final currentState = state as HiveLoaded;
          final updatedHives = currentState.hives
              .where((hive) => hive.id != event.hiveId)
              .toList();
          emit(HiveLoaded(updatedHives));
        }
      }
    } catch (e) {
      _logger.e('Erreur inattendue lors de la suppression de la ruche: $e');
      emit(HiveError('Erreur inattendue: $e'));
    }
  }

  Future<void> _onRefreshHives(
    RefreshHives event,
    Emitter<HiveState> emit,
  ) async {
    if (state is HiveLoaded) {
      final currentState = state as HiveLoaded;
      // Récupérer l'apiaryId depuis les ruches existantes
      if (currentState.hives.isNotEmpty) {
        add(LoadApiaryHives(currentState.hives.first.apiaryId));
      }
    }
  }
}
