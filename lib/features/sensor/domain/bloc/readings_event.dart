import 'package:equatable/equatable.dart';

/// Événements pour le BLoC des lectures de capteurs
abstract class ReadingsEvent extends Equatable {
  const ReadingsEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour charger les dernières lectures pour une ruche
class LoadHiveReadings extends ReadingsEvent {
  final String hiveId;
  final int limit;

  const LoadHiveReadings(this.hiveId, {this.limit = 20});

  @override
  List<Object?> get props => [hiveId, limit];
}

/// Événement pour charger les lectures d'une ruche dans une plage de temps
class LoadHiveReadingsByTimeRange extends ReadingsEvent {
  final String hiveId;
  final DateTime startTime;
  final DateTime endTime;

  const LoadHiveReadingsByTimeRange(
    this.hiveId,
    this.startTime,
    this.endTime,
  );

  @override
  List<Object?> get props => [hiveId, startTime, endTime];
}

/// Événement pour souscrire aux mises à jour des lectures d'une ruche
class SubscribeToHiveReadings extends ReadingsEvent {
  final String hiveId;

  const SubscribeToHiveReadings(this.hiveId);

  @override
  List<Object?> get props => [hiveId];
}

/// Événement pour charger les dernières lectures pour un capteur
class LoadSensorReadings extends ReadingsEvent {
  final String sensorId;
  final int limit;

  const LoadSensorReadings(this.sensorId, {this.limit = 20});

  @override
  List<Object?> get props => [sensorId, limit];
}

/// Événement pour charger les lectures d'un capteur dans une plage de temps
class LoadSensorReadingsByTimeRange extends ReadingsEvent {
  final String sensorId;
  final DateTime startTime;
  final DateTime endTime;

  const LoadSensorReadingsByTimeRange(
    this.sensorId,
    this.startTime,
    this.endTime,
  );

  @override
  List<Object?> get props => [sensorId, startTime, endTime];
}

/// Événement pour souscrire aux mises à jour des lectures d'un capteur
class SubscribeToSensorReadings extends ReadingsEvent {
  final String sensorId;

  const SubscribeToSensorReadings(this.sensorId);

  @override
  List<Object?> get props => [sensorId];
}

/// Événement pour annuler les abonnements
class CancelSubscriptions extends ReadingsEvent {}
