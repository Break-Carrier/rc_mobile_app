import 'package:equatable/equatable.dart';

/// Énumération pour l'état du couvert de la ruche
enum CoverState {
  open('OUVERT'),
  closed('FERME');

  const CoverState(this.value);
  final String value;

  static CoverState fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OUVERT':
        return CoverState.open;
      case 'FERME':
        return CoverState.closed;
      default:
        return CoverState.closed;
    }
  }
}

/// Énumération pour l'état de la LED
enum LedState {
  on('ON'),
  off('OFF');

  const LedState(this.value);
  final String value;

  static LedState fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ON':
        return LedState.on;
      case 'OFF':
        return LedState.off;
      default:
        return LedState.off;
    }
  }
}

/// Représente les données de capteur intégrées dans une ruche
class HiveSensorData extends Equatable {
  final double temperature;
  final double humidity;
  final CoverState coverState;
  final LedState ledState;

  const HiveSensorData({
    required this.temperature,
    required this.humidity,
    required this.coverState,
    required this.ledState,
  });

  /// Créer une instance depuis les données Firebase
  factory HiveSensorData.fromFirebase(Map<String, dynamic> data) {
    return HiveSensorData(
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
      coverState: CoverState.fromString(data['couvert'] as String? ?? 'FERME'),
      ledState: LedState.fromString(data['ledState'] as String? ?? 'OFF'),
    );
  }

  /// Convertir vers Map pour Firebase
  Map<String, dynamic> toFirebase() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'couvert': coverState.value,
      'ledState': ledState.value,
    };
  }

  /// Créer une copie avec des modifications
  HiveSensorData copyWith({
    double? temperature,
    double? humidity,
    CoverState? coverState,
    LedState? ledState,
  }) {
    return HiveSensorData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      coverState: coverState ?? this.coverState,
      ledState: ledState ?? this.ledState,
    );
  }

  @override
  List<Object> get props => [temperature, humidity, coverState, ledState];

  @override
  String toString() {
    return 'HiveSensorData(temperature: $temperature°C, humidity: $humidity%, cover: ${coverState.value}, led: ${ledState.value})';
  }
}
