import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/threshold_event.dart';
import '../../domain/entities/alert_settings.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../domain/usecases/manage_alert_usecase.dart';
import '../../domain/repositories/alert_repository_interface.dart';

// Events
abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlerts extends AlertEvent {
  final int limit;
  const LoadAlerts({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class LoadHiveAlerts extends AlertEvent {
  final String hiveId;
  final int limit;
  const LoadHiveAlerts({required this.hiveId, this.limit = 20});

  @override
  List<Object?> get props => [hiveId, limit];
}

class LoadApiaryAlerts extends AlertEvent {
  final String apiaryId;
  final int limit;
  const LoadApiaryAlerts({required this.apiaryId, this.limit = 20});

  @override
  List<Object?> get props => [apiaryId, limit];
}

class LoadUnreadAlerts extends AlertEvent {
  final int limit;
  const LoadUnreadAlerts({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class LoadCriticalAlerts extends AlertEvent {
  final int limit;
  const LoadCriticalAlerts({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class MarkAlertAsRead extends AlertEvent {
  final String alertId;
  const MarkAlertAsRead({required this.alertId});

  @override
  List<Object?> get props => [alertId];
}

class MarkAlertAsUnread extends AlertEvent {
  final String alertId;
  const MarkAlertAsUnread({required this.alertId});

  @override
  List<Object?> get props => [alertId];
}

class DeleteAlert extends AlertEvent {
  final String alertId;
  const DeleteAlert({required this.alertId});

  @override
  List<Object?> get props => [alertId];
}

class MarkAllHiveAlertsAsRead extends AlertEvent {
  final String hiveId;
  const MarkAllHiveAlertsAsRead({required this.hiveId});

  @override
  List<Object?> get props => [hiveId];
}

class StartMonitoringHive extends AlertEvent {
  final String hiveId;
  final String apiaryId;
  const StartMonitoringHive({required this.hiveId, required this.apiaryId});

  @override
  List<Object?> get props => [hiveId, apiaryId];
}

class StopMonitoringHive extends AlertEvent {
  final String hiveId;
  const StopMonitoringHive({required this.hiveId});

  @override
  List<Object?> get props => [hiveId];
}

class UpdateAlertSettings extends AlertEvent {
  final String hiveId;
  final AlertSettings settings;
  const UpdateAlertSettings({required this.hiveId, required this.settings});

  @override
  List<Object?> get props => [hiveId, settings];
}

// States
abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final List<ThresholdEvent> alerts;
  final bool hasReachedMax;
  final String? currentFilter;

  const AlertLoaded({
    required this.alerts,
    this.hasReachedMax = false,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [alerts, hasReachedMax, currentFilter];

  AlertLoaded copyWith({
    List<ThresholdEvent>? alerts,
    bool? hasReachedMax,
    String? currentFilter,
  }) {
    return AlertLoaded(
      alerts: alerts ?? this.alerts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class AlertError extends AlertState {
  final String message;
  const AlertError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlertActionSuccess extends AlertState {
  final String message;
  const AlertActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlertActionFailure extends AlertState {
  final String message;
  const AlertActionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final GetAlertsUseCase _getAlertsUseCase;
  final ManageAlertUseCase _manageAlertUseCase;
  final IAlertRepository _alertRepository;

  StreamSubscription<List<ThresholdEvent>>? _alertsSubscription;

  AlertBloc({
    required GetAlertsUseCase getAlertsUseCase,
    required ManageAlertUseCase manageAlertUseCase,
    required IAlertRepository alertRepository,
  })  : _getAlertsUseCase = getAlertsUseCase,
        _manageAlertUseCase = manageAlertUseCase,
        _alertRepository = alertRepository,
        super(AlertInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<LoadHiveAlerts>(_onLoadHiveAlerts);
    on<LoadApiaryAlerts>(_onLoadApiaryAlerts);
    on<LoadUnreadAlerts>(_onLoadUnreadAlerts);
    on<LoadCriticalAlerts>(_onLoadCriticalAlerts);
    on<MarkAlertAsRead>(_onMarkAlertAsRead);
    on<MarkAlertAsUnread>(_onMarkAlertAsUnread);
    on<DeleteAlert>(_onDeleteAlert);
    on<MarkAllHiveAlertsAsRead>(_onMarkAllHiveAlertsAsRead);
    on<StartMonitoringHive>(_onStartMonitoringHive);
    on<StopMonitoringHive>(_onStopMonitoringHive);
    on<UpdateAlertSettings>(_onUpdateAlertSettings);
  }

  Future<void> _onLoadAlerts(LoadAlerts event, Emitter<AlertState> emit) async {
    try {
      emit(AlertLoading());
      final alerts = await _getAlertsUseCase(limit: event.limit);
      emit(AlertLoaded(
        alerts: alerts,
        hasReachedMax: alerts.length < event.limit,
        currentFilter: 'all',
      ));
    } catch (e) {
      emit(AlertError(message: 'Erreur lors du chargement des alertes: $e'));
    }
  }

  Future<void> _onLoadHiveAlerts(
      LoadHiveAlerts event, Emitter<AlertState> emit) async {
    try {
      emit(AlertLoading());
      final alerts =
          await _getAlertsUseCase.forHive(event.hiveId, limit: event.limit);
      emit(AlertLoaded(
        alerts: alerts,
        hasReachedMax: alerts.length < event.limit,
        currentFilter: 'hive_${event.hiveId}',
      ));
    } catch (e) {
      emit(AlertError(
          message: 'Erreur lors du chargement des alertes de la ruche: $e'));
    }
  }

  Future<void> _onLoadApiaryAlerts(
      LoadApiaryAlerts event, Emitter<AlertState> emit) async {
    try {
      emit(AlertLoading());
      final alerts =
          await _getAlertsUseCase.forApiary(event.apiaryId, limit: event.limit);
      emit(AlertLoaded(
        alerts: alerts,
        hasReachedMax: alerts.length < event.limit,
        currentFilter: 'apiary_${event.apiaryId}',
      ));
    } catch (e) {
      emit(AlertError(
          message: 'Erreur lors du chargement des alertes du rucher: $e'));
    }
  }

  Future<void> _onLoadUnreadAlerts(
      LoadUnreadAlerts event, Emitter<AlertState> emit) async {
    try {
      emit(AlertLoading());
      final alerts = await _getAlertsUseCase.unread(limit: event.limit);
      emit(AlertLoaded(
        alerts: alerts,
        hasReachedMax: alerts.length < event.limit,
        currentFilter: 'unread',
      ));
    } catch (e) {
      emit(AlertError(
          message: 'Erreur lors du chargement des alertes non lues: $e'));
    }
  }

  Future<void> _onLoadCriticalAlerts(
      LoadCriticalAlerts event, Emitter<AlertState> emit) async {
    try {
      emit(AlertLoading());
      final alerts = await _getAlertsUseCase.critical(limit: event.limit);
      emit(AlertLoaded(
        alerts: alerts,
        hasReachedMax: alerts.length < event.limit,
        currentFilter: 'critical',
      ));
    } catch (e) {
      emit(AlertError(
          message: 'Erreur lors du chargement des alertes critiques: $e'));
    }
  }

  Future<void> _onMarkAlertAsRead(
      MarkAlertAsRead event, Emitter<AlertState> emit) async {
    try {
      final success = await _manageAlertUseCase.markAsRead(event.alertId);
      if (success) {
        emit(AlertActionSuccess(message: 'Alerte marquée comme lue'));
        // Recharger les alertes pour mettre à jour l'état
        add(const LoadAlerts());
      } else {
        emit(const AlertActionFailure(
            message: 'Échec du marquage de l\'alerte'));
      }
    } catch (e) {
      emit(AlertActionFailure(
          message: 'Erreur lors du marquage de l\'alerte: $e'));
    }
  }

  Future<void> _onMarkAlertAsUnread(
      MarkAlertAsUnread event, Emitter<AlertState> emit) async {
    try {
      final success = await _manageAlertUseCase.markAsUnread(event.alertId);
      if (success) {
        emit(AlertActionSuccess(message: 'Alerte marquée comme non lue'));
        // Recharger les alertes pour mettre à jour l'état
        add(const LoadAlerts());
      } else {
        emit(const AlertActionFailure(
            message: 'Échec du marquage de l\'alerte'));
      }
    } catch (e) {
      emit(AlertActionFailure(
          message: 'Erreur lors du marquage de l\'alerte: $e'));
    }
  }

  Future<void> _onDeleteAlert(
      DeleteAlert event, Emitter<AlertState> emit) async {
    try {
      final success = await _manageAlertUseCase.delete(event.alertId);
      if (success) {
        emit(AlertActionSuccess(message: 'Alerte supprimée'));
        // Recharger les alertes pour mettre à jour l'état
        add(const LoadAlerts());
      } else {
        emit(const AlertActionFailure(
            message: 'Échec de la suppression de l\'alerte'));
      }
    } catch (e) {
      emit(AlertActionFailure(
          message: 'Erreur lors de la suppression de l\'alerte: $e'));
    }
  }

  Future<void> _onMarkAllHiveAlertsAsRead(
      MarkAllHiveAlertsAsRead event, Emitter<AlertState> emit) async {
    try {
      final success =
          await _manageAlertUseCase.markAllHiveAlertsAsRead(event.hiveId);
      if (success) {
        emit(AlertActionSuccess(
            message: 'Toutes les alertes de la ruche marquées comme lues'));
        // Recharger les alertes pour mettre à jour l'état
        add(LoadHiveAlerts(hiveId: event.hiveId));
      } else {
        emit(
            const AlertActionFailure(message: 'Échec du marquage des alertes'));
      }
    } catch (e) {
      emit(AlertActionFailure(
          message: 'Erreur lors du marquage des alertes: $e'));
    }
  }

  Future<void> _onStartMonitoringHive(
      StartMonitoringHive event, Emitter<AlertState> emit) async {
    try {
      await _alertRepository.startMonitoringHive(event.hiveId, event.apiaryId);
      emit(AlertActionSuccess(
          message: 'Surveillance des alertes démarrée pour la ruche'));
    } catch (e) {
      emit(AlertActionFailure(
          message: 'Erreur lors du démarrage de la surveillance: $e'));
    }
  }

  Future<void> _onStopMonitoringHive(
      StopMonitoringHive event, Emitter<AlertState> emit) async {
    try {
      await _alertRepository.stopMonitoringHive(event.hiveId);
      emit(AlertActionSuccess(
          message: 'Surveillance des alertes arrêtée pour la ruche'));
    } catch (e) {
      emit(AlertActionFailure(
          message: 'Erreur lors de l\'arrêt de la surveillance: $e'));
    }
  }

  Future<void> _onUpdateAlertSettings(
      UpdateAlertSettings event, Emitter<AlertState> emit) async {
    try {
      await _alertRepository.updateAlertSettings(event.hiveId, event.settings);
      emit(AlertActionSuccess(message: 'Paramètres d\'alertes mis à jour'));
    } catch (e) {
      emit(AlertActionFailure(
          message: 'Erreur lors de la mise à jour des paramètres: $e'));
    }
  }

  /// Démarre l'écoute des alertes en temps réel
  void startListening() {
    _alertsSubscription?.cancel();
    _alertsSubscription = _alertRepository.streamAlerts().listen((alerts) {
      if (state is AlertLoaded) {
        final currentState = state as AlertLoaded;
        emit(currentState.copyWith(alerts: alerts));
      } else {
        emit(AlertLoaded(alerts: alerts, currentFilter: 'realtime'));
      }
    });
  }

  /// Arrête l'écoute des alertes en temps réel
  void stopListening() {
    _alertsSubscription?.cancel();
    _alertsSubscription = null;
  }

  @override
  Future<void> close() {
    stopListening();
    return super.close();
  }
}
