import 'package:equatable/equatable.dart';

/// Représente l'état actuel d'une ruche
class CurrentState extends Equatable {
  final String hiveId;
  final double? temperature;
  final double? humidity;
  final double? weight;
  final bool isOnline;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const CurrentState({
    required this.hiveId,
    this.temperature,
    this.humidity,
    this.weight,
    required this.isOnline,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        hiveId,
        temperature,
        humidity,
        weight,
        isOnline,
        timestamp,
        metadata,
      ];
}
