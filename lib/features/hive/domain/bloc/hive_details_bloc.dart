import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/current_state.dart';
import '../../../../models/hive.dart';
import '../../data/repositories/hive_repository.dart';
import '../repositories/hive_repository_interface.dart';

// Événements
abstract class HiveDetailsEvent {}

class LoadHiveDetails extends HiveDetailsEvent {
  final String hiveId;

  LoadHiveDetails({required this.hiveId});
}

class RefreshHiveDetails extends HiveDetailsEvent {}

class UpdateTemperatureThresholds extends HiveDetailsEvent {
  final double lowThreshold;
  final double highThreshold;

  UpdateTemperatureThresholds({
    required this.lowThreshold,
    required this.highThreshold,
  });
}

// États
abstract class HiveDetailsState {}

class HiveDetailsInitial extends HiveDetailsState {}

class HiveDetailsLoading extends HiveDetailsState {}

class HiveDetailsLoaded extends HiveDetailsState {
  final Hive? hive;
  final CurrentState? currentState;
  final String hiveId;

  HiveDetailsLoaded({
    required this.hiveId,
    this.hive,
    this.currentState,
  });

  HiveDetailsLoaded copyWith({
    Hive? hive,
    CurrentState? currentState,
  }) {
    return HiveDetailsLoaded(
      hiveId: this.hiveId,
      hive: hive ?? this.hive,
      currentState: currentState ?? this.currentState,
    );
  }
}

class HiveDetailsError extends HiveDetailsState {
  final String message;

  HiveDetailsError({required this.message});
}

// BLoC
class HiveDetailsBloc extends Bloc<HiveDetailsEvent, HiveDetailsState> {
  final IHiveRepository _hiveRepository;
  String? _currentHiveId;
  StreamSubscription? _currentStateSubscription;

  HiveDetailsBloc({
    IHiveRepository? hiveRepository,
  })  : _hiveRepository = hiveRepository ?? HiveRepository(),
        super(HiveDetailsInitial()) {
    on<LoadHiveDetails>(_onLoadHiveDetails);
    on<RefreshHiveDetails>(_onRefreshHiveDetails);
    on<UpdateTemperatureThresholds>(_onUpdateTemperatureThresholds);
  }

  Future<void> _onLoadHiveDetails(
      LoadHiveDetails event, Emitter<HiveDetailsState> emit) async {
    try {
      emit(HiveDetailsLoading());

      _currentHiveId = event.hiveId;

      // Charger les détails de la ruche
      final hive = await _hiveRepository.getHiveById(event.hiveId);

      // État initial avec la ruche chargée
      emit(HiveDetailsLoaded(
        hiveId: event.hiveId,
        hive: hive,
        currentState: null,
      ));

      // S'abonner au flux d'état actuel
      await _currentStateSubscription?.cancel();
      _currentStateSubscription =
          _hiveRepository.getCurrentState(event.hiveId).listen((currentState) {
        if (state is HiveDetailsLoaded) {
          final currentLoadedState = state as HiveDetailsLoaded;
          emit(currentLoadedState.copyWith(currentState: currentState));
        }
      });
    } catch (e) {
      debugPrint('❌ Error loading hive details: $e');
      emit(HiveDetailsError(
          message: 'Erreur lors du chargement des détails: $e'));
    }
  }

  Future<void> _onRefreshHiveDetails(
      RefreshHiveDetails event, Emitter<HiveDetailsState> emit) async {
    if (_currentHiveId != null) {
      add(LoadHiveDetails(hiveId: _currentHiveId!));
    }
  }

  Future<void> _onUpdateTemperatureThresholds(
      UpdateTemperatureThresholds event, Emitter<HiveDetailsState> emit) async {
    if (_currentHiveId == null) return;

    try {
      await _hiveRepository.updateTemperatureThresholds(
        _currentHiveId!,
        event.lowThreshold,
        event.highThreshold,
      );

      // Rafraîchir les détails
      add(RefreshHiveDetails());
    } catch (e) {
      debugPrint('❌ Error updating temperature thresholds: $e');
      emit(HiveDetailsError(
        message: 'Erreur lors de la mise à jour des seuils: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _currentStateSubscription?.cancel();
    return super.close();
  }
}
 