import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/apiary.dart';
import '../../../../core/models/hive.dart';
import '../../../../core/models/sensor_reading.dart';
import '../../../../core/models/time_filter.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../../core/factories/service_factory.dart';

// Events
abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final TimeFilter timeFilter;

  LoadDashboardData({this.timeFilter = TimeFilter.oneHour});
}

class RefreshDashboardData extends DashboardEvent {}

class ChangeTimeFilter extends DashboardEvent {
  final TimeFilter timeFilter;

  ChangeTimeFilter({required this.timeFilter});
}

// States
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Apiary> apiaries;
  final List<Hive> hives;
  final List<SensorReading> averageTemperatureReadings;
  final TimeFilter currentTimeFilter;
  final String? selectedHiveId;

  DashboardLoaded({
    required this.apiaries,
    required this.hives,
    required this.averageTemperatureReadings,
    required this.currentTimeFilter,
    this.selectedHiveId,
  });

  DashboardLoaded copyWith({
    List<Apiary>? apiaries,
    List<Hive>? hives,
    List<SensorReading>? averageTemperatureReadings,
    TimeFilter? currentTimeFilter,
    String? selectedHiveId,
  }) {
    return DashboardLoaded(
      apiaries: apiaries ?? this.apiaries,
      hives: hives ?? this.hives,
      averageTemperatureReadings:
          averageTemperatureReadings ?? this.averageTemperatureReadings,
      currentTimeFilter: currentTimeFilter ?? this.currentTimeFilter,
      selectedHiveId: selectedHiveId ?? this.selectedHiveId,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final coordinator = ServiceFactory.getHiveServiceCoordinator();
  final DashboardRepository _dashboardRepository;

  DashboardBloc({
    DashboardRepository? dashboardRepository,
  })  : _dashboardRepository = dashboardRepository ?? DashboardRepository(),
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<ChangeTimeFilter>(_onChangeTimeFilter);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    try {
      emit(DashboardLoading());

      // Récupérer les ruchers et les ruches
      final apiaries = await coordinator.getApiaries();

      if (apiaries.isEmpty) {
        emit(DashboardLoaded(
          apiaries: [],
          hives: [],
          averageTemperatureReadings: [],
          currentTimeFilter: event.timeFilter,
        ));
        return;
      }

      // Récupérer les ruches du premier rucher
      final hives = await coordinator.getHivesForApiary(apiaries.first.id);

      // Récupérer les données de température moyenne
      final averageTemperatureReadings = await _dashboardRepository
          .getAverageTemperatureForApiary(apiaries.first.id, event.timeFilter);

      // Mettre à jour le time filter dans le coordinator aussi
      coordinator.setTimeFilter(event.timeFilter);

      // Sélectionner la première ruche si disponible
      final selectedHiveId = hives.isNotEmpty ? hives.first.id : null;
      if (selectedHiveId != null) {
        coordinator.setActiveHive(selectedHiveId);
      }

      emit(DashboardLoaded(
        apiaries: apiaries,
        hives: hives,
        averageTemperatureReadings: averageTemperatureReadings,
        currentTimeFilter: event.timeFilter,
        selectedHiveId: selectedHiveId,
      ));
    } catch (e) {
      debugPrint('❌ Error loading dashboard data: $e');
      emit(
          DashboardError(message: 'Erreur lors du chargement des données: $e'));
    }
  }

  Future<void> _onRefreshDashboardData(
      RefreshDashboardData event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      await coordinator.refreshAllData();

      add(LoadDashboardData(timeFilter: currentState.currentTimeFilter));
    } else {
      add(LoadDashboardData());
    }
  }

  Future<void> _onChangeTimeFilter(
      ChangeTimeFilter event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      // Mettre à jour le filtre dans le coordinator
      coordinator.setTimeFilter(event.timeFilter);

      if (currentState.apiaries.isNotEmpty) {
        // Récupérer les nouvelles données de température moyenne
        final newAverageTemperatureReadings =
            await _dashboardRepository.getAverageTemperatureForApiary(
                currentState.apiaries.first.id, event.timeFilter);

        emit(currentState.copyWith(
          currentTimeFilter: event.timeFilter,
          averageTemperatureReadings: newAverageTemperatureReadings,
        ));
      } else {
        emit(currentState.copyWith(
          currentTimeFilter: event.timeFilter,
        ));
      }
    }
  }
}
