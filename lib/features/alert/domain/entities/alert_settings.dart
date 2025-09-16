import 'package:equatable/equatable.dart';

/// Paramètres de configuration des alertes pour une ruche ou un rucher
class AlertSettings extends Equatable {
  final String? id;
  final String? hiveId;
  final String? apiaryId;
  final double temperatureHighThreshold;
  final double temperatureLowThreshold;
  final double humidityHighThreshold;
  final double humidityLowThreshold;
  final bool isEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlertSettings({
    this.id,
    this.hiveId,
    this.apiaryId,
    required this.temperatureHighThreshold,
    required this.temperatureLowThreshold,
    required this.humidityHighThreshold,
    required this.humidityLowThreshold,
    this.isEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Vérifie si les paramètres sont valides
  bool get isValid {
    return temperatureHighThreshold > temperatureLowThreshold &&
        humidityHighThreshold > humidityLowThreshold &&
        temperatureHighThreshold > 0 &&
        temperatureLowThreshold > 0 &&
        humidityHighThreshold > 0 &&
        humidityLowThreshold > 0;
  }

  /// Vérifie si une température déclenche une alerte
  bool isTemperatureAlert(double temperature) {
    if (!isEnabled) return false;
    return temperature > temperatureHighThreshold ||
        temperature < temperatureLowThreshold;
  }

  /// Vérifie si une humidité déclenche une alerte
  bool isHumidityAlert(double humidity) {
    if (!isEnabled) return false;
    return humidity > humidityHighThreshold || humidity < humidityLowThreshold;
  }

  /// Détermine le type d'alerte pour une température
  String? getTemperatureAlertType(double temperature) {
    if (!isEnabled) return null;
    if (temperature > temperatureHighThreshold) {
      return 'temperature_high';
    } else if (temperature < temperatureLowThreshold) {
      return 'temperature_low';
    }
    return null;
  }

  /// Détermine le type d'alerte pour une humidité
  String? getHumidityAlertType(double humidity) {
    if (!isEnabled) return null;
    if (humidity > humidityHighThreshold) {
      return 'humidity_high';
    } else if (humidity < humidityLowThreshold) {
      return 'humidity_low';
    }
    return null;
  }

  /// Crée une copie avec certains attributs modifiés
  AlertSettings copyWith({
    String? id,
    String? hiveId,
    String? apiaryId,
    double? temperatureHighThreshold,
    double? temperatureLowThreshold,
    double? humidityHighThreshold,
    double? humidityLowThreshold,
    bool? isEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlertSettings(
      id: id ?? this.id,
      hiveId: hiveId ?? this.hiveId,
      apiaryId: apiaryId ?? this.apiaryId,
      temperatureHighThreshold:
          temperatureHighThreshold ?? this.temperatureHighThreshold,
      temperatureLowThreshold:
          temperatureLowThreshold ?? this.temperatureLowThreshold,
      humidityHighThreshold:
          humidityHighThreshold ?? this.humidityHighThreshold,
      humidityLowThreshold: humidityLowThreshold ?? this.humidityLowThreshold,
      isEnabled: isEnabled ?? this.isEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AlertSettings(id: $id, hiveId: $hiveId, apiaryId: $apiaryId, '
        'tempHigh: $temperatureHighThreshold, tempLow: $temperatureLowThreshold, '
        'enabled: $isEnabled)';
  }

  @override
  List<Object?> get props => [
        id,
        hiveId,
        apiaryId,
        temperatureHighThreshold,
        temperatureLowThreshold,
        humidityHighThreshold,
        humidityLowThreshold,
        isEnabled,
        emailNotifications,
        pushNotifications,
        smsNotifications,
        createdAt,
        updatedAt,
      ];
}
