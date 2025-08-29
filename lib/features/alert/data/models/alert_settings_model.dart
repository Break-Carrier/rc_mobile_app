import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/alert_settings.dart';

/// Modèle de données pour les paramètres d'alertes
class AlertSettingsModel extends AlertSettings {
  /// Constructeur pour créer un nouveau modèle de paramètres
  const AlertSettingsModel({
    super.id,
    super.hiveId,
    super.apiaryId,
    required super.temperatureHighThreshold,
    required super.temperatureLowThreshold,
    required super.humidityHighThreshold,
    required super.humidityLowThreshold,
    super.isEnabled,
    super.emailNotifications,
    super.pushNotifications,
    super.smsNotifications,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Constructeur à partir des données Firebase Realtime Database
  factory AlertSettingsModel.fromRealtimeDB(Map<String, dynamic> data,
      [String? key]) {
    return AlertSettingsModel(
      id: key,
      hiveId: data['hive_id'] as String?,
      apiaryId: data['apiary_id'] as String?,
      temperatureHighThreshold:
          (data['temperature_high_threshold'] as num?)?.toDouble() ?? 30.0,
      temperatureLowThreshold:
          (data['temperature_low_threshold'] as num?)?.toDouble() ?? 15.0,
      humidityHighThreshold:
          (data['humidity_high_threshold'] as num?)?.toDouble() ?? 80.0,
      humidityLowThreshold:
          (data['humidity_low_threshold'] as num?)?.toDouble() ?? 40.0,
      isEnabled: data['is_enabled'] as bool? ?? true,
      emailNotifications: data['email_notifications'] as bool? ?? true,
      pushNotifications: data['push_notifications'] as bool? ?? true,
      smsNotifications: data['sms_notifications'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          data['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Constructeur à partir des données Firestore
  factory AlertSettingsModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return AlertSettingsModel(
      id: id,
      hiveId: data['hive_id'] as String?,
      apiaryId: data['apiary_id'] as String?,
      temperatureHighThreshold:
          (data['temperature_high_threshold'] as num?)?.toDouble() ?? 30.0,
      temperatureLowThreshold:
          (data['temperature_low_threshold'] as num?)?.toDouble() ?? 15.0,
      humidityHighThreshold:
          (data['humidity_high_threshold'] as num?)?.toDouble() ?? 80.0,
      humidityLowThreshold:
          (data['humidity_low_threshold'] as num?)?.toDouble() ?? 40.0,
      isEnabled: data['is_enabled'] as bool? ?? true,
      emailNotifications: data['email_notifications'] as bool? ?? true,
      pushNotifications: data['push_notifications'] as bool? ?? true,
      smsNotifications: data['sms_notifications'] as bool? ?? false,
      createdAt: data['created_at'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int)
          : (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
          : (data['updated_at'] as Timestamp).toDate(),
    );
  }

  /// Convertir en Map pour Firebase Realtime Database
  Map<String, dynamic> toRealtimeDBMap() {
    return {
      'hive_id': hiveId,
      'apiary_id': apiaryId,
      'temperature_high_threshold': temperatureHighThreshold,
      'temperature_low_threshold': temperatureLowThreshold,
      'humidity_high_threshold': humidityHighThreshold,
      'humidity_low_threshold': humidityLowThreshold,
      'is_enabled': isEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'hive_id': hiveId,
      'apiary_id': apiaryId,
      'temperature_high_threshold': temperatureHighThreshold,
      'temperature_low_threshold': temperatureLowThreshold,
      'humidity_high_threshold': humidityHighThreshold,
      'humidity_low_threshold': humidityLowThreshold,
      'is_enabled': isEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Crée un modèle à partir d'une entité
  factory AlertSettingsModel.fromEntity(AlertSettings entity) {
    return AlertSettingsModel(
      id: entity.id,
      hiveId: entity.hiveId,
      apiaryId: entity.apiaryId,
      temperatureHighThreshold: entity.temperatureHighThreshold,
      temperatureLowThreshold: entity.temperatureLowThreshold,
      humidityHighThreshold: entity.humidityHighThreshold,
      humidityLowThreshold: entity.humidityLowThreshold,
      isEnabled: entity.isEnabled,
      emailNotifications: entity.emailNotifications,
      pushNotifications: entity.pushNotifications,
      smsNotifications: entity.smsNotifications,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crée une copie du modèle avec certains attributs modifiés
  @override
  AlertSettingsModel copyWith({
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
    return AlertSettingsModel(
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

  /// Crée des paramètres par défaut pour une ruche
  factory AlertSettingsModel.defaultForHive(String hiveId) {
    final now = DateTime.now();
    return AlertSettingsModel(
      hiveId: hiveId,
      temperatureHighThreshold: 30.0,
      temperatureLowThreshold: 15.0,
      humidityHighThreshold: 80.0,
      humidityLowThreshold: 40.0,
      isEnabled: true,
      emailNotifications: true,
      pushNotifications: true,
      smsNotifications: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Crée des paramètres par défaut pour un rucher
  factory AlertSettingsModel.defaultForApiary(String apiaryId) {
    final now = DateTime.now();
    return AlertSettingsModel(
      apiaryId: apiaryId,
      temperatureHighThreshold: 30.0,
      temperatureLowThreshold: 15.0,
      humidityHighThreshold: 80.0,
      humidityLowThreshold: 40.0,
      isEnabled: true,
      emailNotifications: true,
      pushNotifications: true,
      smsNotifications: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}
