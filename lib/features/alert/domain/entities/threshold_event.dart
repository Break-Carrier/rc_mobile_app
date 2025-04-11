import 'package:equatable/equatable.dart';

/// Type d'événement de seuil
enum ThresholdEventType {
  /// Dépassement de seuil (peut être haut ou bas)
  exceeded,

  /// Retour à la normale
  normal
}

/// Représente un événement de dépassement de seuil
class ThresholdEvent extends Equatable {
  final String? id;
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final ThresholdEventType eventType;
  final double thresholdHigh;
  final double thresholdLow;
  final String? hiveId;
  final String? apiaryId;
  final bool isRead;

  /// Constructeur pour créer un nouvel événement
  const ThresholdEvent({
    this.id,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.eventType,
    required this.thresholdHigh,
    required this.thresholdLow,
    this.hiveId,
    this.apiaryId,
    this.isRead = false,
  });

  /// Déterminer si c'est un dépassement de seuil
  bool get isExceeded => eventType == ThresholdEventType.exceeded;

  /// Déterminer si c'est un retour à la normale
  bool get isNormal => eventType == ThresholdEventType.normal;

  /// Déterminer si la température est au-dessus du seuil haut
  bool get isHighTemperature => temperature > thresholdHigh;

  /// Déterminer si la température est en-dessous du seuil bas
  bool get isLowTemperature => temperature < thresholdLow;

  /// Description de l'événement
  String get description {
    if (isExceeded) {
      if (isHighTemperature) {
        return 'Température élevée: $temperature°C (seuil: $thresholdHigh°C)';
      } else if (isLowTemperature) {
        return 'Température basse: $temperature°C (seuil: $thresholdLow°C)';
      } else {
        return 'Seuil dépassé: $temperature°C';
      }
    } else {
      return 'Retour à la normale: $temperature°C';
    }
  }

  /// Crée une copie de cet événement avec certains attributs modifiés
  ThresholdEvent copyWith({
    String? id,
    double? temperature,
    double? humidity,
    DateTime? timestamp,
    ThresholdEventType? eventType,
    double? thresholdHigh,
    double? thresholdLow,
    String? hiveId,
    String? apiaryId,
    bool? isRead,
  }) {
    return ThresholdEvent(
      id: id ?? this.id,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      timestamp: timestamp ?? this.timestamp,
      eventType: eventType ?? this.eventType,
      thresholdHigh: thresholdHigh ?? this.thresholdHigh,
      thresholdLow: thresholdLow ?? this.thresholdLow,
      hiveId: hiveId ?? this.hiveId,
      apiaryId: apiaryId ?? this.apiaryId,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'ThresholdEvent(type: $eventType, temp: $temperature°C, time: ${timestamp.toIso8601String()})';
  }

  @override
  List<Object?> get props => [
        id,
        temperature,
        humidity,
        timestamp,
        eventType,
        thresholdHigh,
        thresholdLow,
        hiveId,
        apiaryId,
        isRead,
      ];
}
