import '../repositories/sensor_repository.dart';
import '../models/hive.dart';
import '../models/apiary.dart';
import '../models/current_state.dart';
import '../models/sensor_reading.dart';
import '../models/threshold_event.dart';
import '../models/time_filter.dart';

/// Cas d'utilisation pour initialiser le dashboard
class InitializeDashboardUseCase {
  final ISensorRepository _repository;

  InitializeDashboardUseCase(this._repository);

  Future<DashboardData> execute() async {
    final apiaries = await _repository.getApiaries();

    if (apiaries.isEmpty) {
      return DashboardData(
        apiaries: [],
        hives: [],
        selectedHiveId: null,
      );
    }

    final hives = await _repository.getHivesForApiary(apiaries.first.id);
    final selectedHiveId = hives.isNotEmpty ? hives.first.id : null;

    return DashboardData(
      apiaries: apiaries,
      hives: hives,
      selectedHiveId: selectedHiveId,
    );
  }
}

/// Cas d'utilisation pour obtenir l'état actuel d'une ruche
class GetCurrentStateUseCase {
  final ISensorRepository _repository;

  GetCurrentStateUseCase(this._repository);

  Stream<CurrentState?> execute(String hiveId) {
    return _repository.getCurrentState(hiveId);
  }
}

/// Cas d'utilisation pour obtenir les lectures de capteurs
class GetSensorReadingsUseCase {
  final ISensorRepository _repository;

  GetSensorReadingsUseCase(this._repository);

  Stream<List<SensorReading>> execute(String hiveId, TimeFilter timeFilter) {
    return _repository.getSensorReadings(hiveId, timeFilter);
  }
}

/// Cas d'utilisation pour obtenir les événements de dépassement de seuil
class GetThresholdEventsUseCase {
  final ISensorRepository _repository;

  GetThresholdEventsUseCase(this._repository);

  Stream<List<ThresholdEvent>> execute(String hiveId) {
    return _repository.getThresholdEvents(hiveId);
  }
}

/// Cas d'utilisation pour mettre à jour les seuils
class UpdateThresholdsUseCase {
  final ISensorRepository _repository;

  UpdateThresholdsUseCase(this._repository);

  Future<void> execute(
      String hiveId, double lowThreshold, double highThreshold) {
    return _repository.updateThresholds(hiveId, lowThreshold, highThreshold);
  }
}

/// Cas d'utilisation pour rafraîchir toutes les données
class RefreshDataUseCase {
  final ISensorRepository _repository;

  RefreshDataUseCase(this._repository);

  Future<void> execute() {
    return _repository.refreshAllData();
  }
}

/// Cas d'utilisation pour vérifier la connexion
class CheckConnectionUseCase {
  final ISensorRepository _repository;

  CheckConnectionUseCase(this._repository);

  Future<bool> execute() {
    return _repository.checkConnection();
  }
}

/// Données du dashboard
class DashboardData {
  final List<Apiary> apiaries;
  final List<Hive> hives;
  final String? selectedHiveId;

  const DashboardData({
    required this.apiaries,
    required this.hives,
    this.selectedHiveId,
  });
}
