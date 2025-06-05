import 'package:equatable/equatable.dart';

/// Représente un événement de dépassement de seuil
class ThresholdEvent extends Equatable {
  final String id;
  final String hiveId;
  final String type;
  final double value;
  final double threshold;
  final String severity;
  final DateTime timestamp;
  final bool isResolved;
  final Map<String, dynamic>? metadata;

  const ThresholdEvent({
    required this.id,
    required this.hiveId,
    required this.type,
    required this.value,
    required this.threshold,
    required this.severity,
    required this.timestamp,
    required this.isResolved,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        hiveId,
        type,
        value,
        threshold,
        severity,
        timestamp,
        isResolved,
        metadata,
      ];
}
