import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../models/hive.dart';
import '../../../../models/apiary.dart';
import '../../../../models/current_state.dart';
import '../../../../core/services/hive_service_coordinator.dart';
import '../../../../core/factories/service_factory.dart';

// États
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Apiary> apiaries;
  final List<Hive> hives;
  final String? selectedHiveId;
  final CurrentState? currentState;

  const DashboardLoaded({
    required this.apiaries,
    required this.hives,
    this.selectedHiveId,
    this.currentState,
  });

  @override
  List<Object?> get props => [apiaries, hives, selectedHiveId, currentState];

  DashboardLoaded copyWith({
    List<Apiary>? apiaries,
    List<Hive>? hives,
    String? selectedHiveId,
    CurrentState? currentState,
  }) {
    return DashboardLoaded(
      apiaries: apiaries ?? this.apiaries,
      hives: hives ?? this.hives,
      selectedHiveId: selectedHiveId ?? this.selectedHiveId,
      currentState: currentState ?? this.currentState,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

// Événements
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class SelectHive extends DashboardEvent {
  final String hiveId;

  const SelectHive(this.hiveId);

  @override
  List<Object> get props => [hiveId];
}

class RefreshDashboard extends DashboardEvent {}

class UpdateCurrentState extends DashboardEvent {
  final CurrentState? currentState;

  const UpdateCurrentState(this.currentState);

  @override
  List<Object?> get props => [currentState];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final HiveServiceCoordinator _coordinator;
  StreamSubscription? _currentStateSubscription;

  DashboardBloc({required HiveServiceCoordinator sensorService})
      : _coordinator = sensorService,
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<SelectHive>(_onSelectHive);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<UpdateCurrentState>(_onUpdateCurrentState);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      // Attendre que le coordinateur soit initialisé
      if (!_coordinator.isInitialized) {
        // Timeout pour éviter l'attente infinie
        final timeout = Future.delayed(const Duration(seconds: 10));
        final initialized = Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return !_coordinator.isInitialized;
        });

        await Future.any([timeout, initialized]);
      }

      if (!_coordinator.isInitialized) {
        emit(const DashboardError('Services non initialisés'));
        return;
      }

      // Utiliser le coordinateur pour obtenir les données
      final apiaries = await _coordinator.getApiaries();
      List<Hive> hives = [];
      String? selectedHiveId;

      if (apiaries.isNotEmpty) {
        hives = await _coordinator.getHivesForApiary(apiaries.first.id);
        if (hives.isNotEmpty) {
          selectedHiveId = hives.first.id;
          await _coordinator.setActiveHive(selectedHiveId);
        }
      }

      emit(DashboardLoaded(
        apiaries: apiaries,
        hives: hives,
        selectedHiveId: selectedHiveId,
      ));

      // Écouter l'état actuel si une ruche est sélectionnée
      if (selectedHiveId != null) {
        _listenToCurrentState();
      }
    } catch (e) {
      emit(DashboardError('Erreur lors du chargement: $e'));
    }
  }

  Future<void> _onSelectHive(
    SelectHive event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      await _coordinator.setActiveHive(event.hiveId);

      emit(currentState.copyWith(selectedHiveId: event.hiveId));

      _listenToCurrentState();
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    await _coordinator.refreshAllData();
    add(LoadDashboard());
  }

  Future<void> _onUpdateCurrentState(
    UpdateCurrentState event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(currentState: event.currentState));
    }
  }

  void _listenToCurrentState() {
    _currentStateSubscription?.cancel();
    _currentStateSubscription = _coordinator.getCurrentStateStream().listen(
      (currentState) {
        add(UpdateCurrentState(currentState));
      },
    );
  }

  @override
  Future<void> close() {
    _currentStateSubscription?.cancel();
    return super.close();
  }
}
