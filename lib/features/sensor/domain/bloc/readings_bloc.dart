import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../entities/sensor_reading.dart';
import '../repositories/sensor_repository_interface.dart';
import 'readings_event.dart';
import 'readings_state.dart';

/// BLoC pour la gestion des lectures de capteurs
class ReadingsBloc extends Bloc<ReadingsEvent, ReadingsState> {
  final ISensorRepository _repository;
  StreamSubscription? _readingsSubscription;

  ReadingsBloc(this._repository) : super(ReadingsInitial()) {
    on<LoadHiveReadings>(_onLoadHiveReadings);
    on<LoadHiveReadingsByTimeRange>(_onLoadHiveReadingsByTimeRange);
    on<SubscribeToHiveReadings>(_onSubscribeToHiveReadings);
    on<LoadSensorReadings>(_onLoadSensorReadings);
    on<LoadSensorReadingsByTimeRange>(_onLoadSensorReadingsByTimeRange);
    on<SubscribeToSensorReadings>(_onSubscribeToSensorReadings);
    on<CancelSubscriptions>(_onCancelSubscriptions);
    on<_UpdateReadings>(_onUpdateReadings);
    on<_ReadingsError>(_onReadingsError);
  }

  /// Gère l'événement pour charger les dernières lectures d'une ruche
  Future<void> _onLoadHiveReadings(
    LoadHiveReadings event,
    Emitter<ReadingsState> emit,
  ) async {
    emit(ReadingsLoading());
    try {
      final readings = await _repository.getLatestReadingsForHive(
        event.hiveId,
        limit: event.limit,
      );
      emit(ReadingsLoaded(
        readings: readings,
        hiveId: event.hiveId,
      ));
    } catch (e) {
      emit(ReadingsError('Erreur lors du chargement des lectures: $e'));
    }
  }

  /// Gère l'événement pour charger les lectures d'une ruche dans une plage de temps
  Future<void> _onLoadHiveReadingsByTimeRange(
    LoadHiveReadingsByTimeRange event,
    Emitter<ReadingsState> emit,
  ) async {
    emit(ReadingsLoading());
    try {
      final readings = await _repository.getReadingsForHiveByTimeRange(
        event.hiveId,
        event.startTime,
        event.endTime,
      );
      emit(ReadingsLoaded(
        readings: readings,
        hiveId: event.hiveId,
      ));
    } catch (e) {
      emit(ReadingsError(
          'Erreur lors du chargement des lectures par plage de temps: $e'));
    }
  }

  /// Gère l'événement pour s'abonner aux mises à jour des lectures d'une ruche
  Future<void> _onSubscribeToHiveReadings(
    SubscribeToHiveReadings event,
    Emitter<ReadingsState> emit,
  ) async {
    _cancelSubscription();
    emit(ReadingsLoading());

    try {
      // D'abord, charger les données initiales
      List<SensorReading> initialReadings =
          await _repository.getLatestReadingsForHive(event.hiveId);

      // Émettre l'état initial
      emit(ReadingsLoaded(
        readings: initialReadings,
        hiveId: event.hiveId,
        isStreaming: true,
      ));

      // S'abonner au flux
      _readingsSubscription =
          _repository.streamReadingsForHive(event.hiveId).listen(
        (readings) {
          // Si le bloc est toujours actif, émettre le nouvel état
          if (!isClosed) {
            add(_UpdateReadings(readings, event.hiveId, null));
          }
        },
        onError: (error) {
          if (!isClosed) {
            add(_ReadingsError('Erreur de flux: $error'));
          }
        },
      );
    } catch (e) {
      emit(ReadingsError('Erreur d\'abonnement aux lectures: $e'));
    }
  }

  /// Gère l'événement pour charger les dernières lectures d'un capteur
  Future<void> _onLoadSensorReadings(
    LoadSensorReadings event,
    Emitter<ReadingsState> emit,
  ) async {
    emit(ReadingsLoading());
    try {
      final readings = await _repository.getLatestReadings(
        event.sensorId,
        limit: event.limit,
      );
      emit(ReadingsLoaded(
        readings: readings,
        sensorId: event.sensorId,
      ));
    } catch (e) {
      emit(ReadingsError('Erreur lors du chargement des lectures: $e'));
    }
  }

  /// Gère l'événement pour charger les lectures d'un capteur dans une plage de temps
  Future<void> _onLoadSensorReadingsByTimeRange(
    LoadSensorReadingsByTimeRange event,
    Emitter<ReadingsState> emit,
  ) async {
    emit(ReadingsLoading());
    try {
      final readings = await _repository.getReadingsByTimeRange(
        event.sensorId,
        event.startTime,
        event.endTime,
      );
      emit(ReadingsLoaded(
        readings: readings,
        sensorId: event.sensorId,
      ));
    } catch (e) {
      emit(ReadingsError(
          'Erreur lors du chargement des lectures par plage de temps: $e'));
    }
  }

  /// Gère l'événement pour s'abonner aux mises à jour des lectures d'un capteur
  Future<void> _onSubscribeToSensorReadings(
    SubscribeToSensorReadings event,
    Emitter<ReadingsState> emit,
  ) async {
    _cancelSubscription();
    emit(ReadingsLoading());

    try {
      // D'abord, charger les données initiales
      List<SensorReading> initialReadings =
          await _repository.getLatestReadings(event.sensorId);

      // Émettre l'état initial
      emit(ReadingsLoaded(
        readings: initialReadings,
        sensorId: event.sensorId,
        isStreaming: true,
      ));

      // S'abonner au flux
      _readingsSubscription = _repository.streamReadings(event.sensorId).listen(
        (readings) {
          // Si le bloc est toujours actif, émettre le nouvel état
          if (!isClosed) {
            add(_UpdateReadings(readings, null, event.sensorId));
          }
        },
        onError: (error) {
          if (!isClosed) {
            add(_ReadingsError('Erreur de flux: $error'));
          }
        },
      );
    } catch (e) {
      emit(ReadingsError('Erreur d\'abonnement aux lectures: $e'));
    }
  }

  /// Gère l'événement pour annuler les abonnements
  Future<void> _onCancelSubscriptions(
    CancelSubscriptions event,
    Emitter<ReadingsState> emit,
  ) async {
    _cancelSubscription();
    emit(ReadingsInitial());
  }

  /// Annule l'abonnement actuel s'il existe
  void _cancelSubscription() {
    _readingsSubscription?.cancel();
    _readingsSubscription = null;
  }

  /// Événement interne pour mettre à jour les lectures
  void _onUpdateReadings(
    _UpdateReadings event,
    Emitter<ReadingsState> emit,
  ) {
    final currentState = state;
    if (currentState is ReadingsLoaded) {
      emit(currentState.copyWith(
        readings: event.readings,
        hiveId: event.hiveId ?? currentState.hiveId,
        sensorId: event.sensorId ?? currentState.sensorId,
      ));
    } else {
      emit(ReadingsLoaded(
        readings: event.readings,
        hiveId: event.hiveId,
        sensorId: event.sensorId,
        isStreaming: true,
      ));
    }
  }

  /// Événement interne pour gérer les erreurs
  void _onReadingsError(
    _ReadingsError event,
    Emitter<ReadingsState> emit,
  ) {
    emit(ReadingsError(event.message));
  }

  @override
  Future<void> close() {
    _cancelSubscription();
    return super.close();
  }
}

/// Événement interne pour mettre à jour les lectures
class _UpdateReadings extends ReadingsEvent {
  final List<SensorReading> readings;
  final String? hiveId;
  final String? sensorId;

  const _UpdateReadings(this.readings, this.hiveId, this.sensorId);

  @override
  List<Object?> get props => [readings, hiveId, sensorId];
}

/// Événement interne pour gérer les erreurs
class _ReadingsError extends ReadingsEvent {
  final String message;

  const _ReadingsError(this.message);

  @override
  List<Object?> get props => [message];
}
