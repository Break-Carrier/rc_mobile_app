import 'package:equatable/equatable.dart';
import '../entities/sensor_reading.dart';

/// États pour le BLoC des lectures de capteurs
abstract class ReadingsState extends Equatable {
  const ReadingsState();

  @override
  List<Object?> get props => [];
}

/// État initial
class ReadingsInitial extends ReadingsState {}

/// État de chargement
class ReadingsLoading extends ReadingsState {}

/// État de chargement réussi
class ReadingsLoaded extends ReadingsState {
  final List<SensorReading> readings;
  final String? hiveId;
  final String? sensorId;
  final bool isStreaming;

  const ReadingsLoaded({
    required this.readings,
    this.hiveId,
    this.sensorId,
    this.isStreaming = false,
  });

  @override
  List<Object?> get props => [readings, hiveId, sensorId, isStreaming];

  /// Crée une copie avec des modifications
  ReadingsLoaded copyWith({
    List<SensorReading>? readings,
    String? hiveId,
    String? sensorId,
    bool? isStreaming,
  }) {
    return ReadingsLoaded(
      readings: readings ?? this.readings,
      hiveId: hiveId ?? this.hiveId,
      sensorId: sensorId ?? this.sensorId,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

/// État d'erreur
class ReadingsError extends ReadingsState {
  final String message;

  const ReadingsError(this.message);

  @override
  List<Object?> get props => [message];
} 