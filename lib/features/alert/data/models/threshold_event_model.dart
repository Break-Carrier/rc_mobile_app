import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/threshold_event.dart';

/// Modèle de données pour les événements de dépassement de seuil
class ThresholdEventModel extends ThresholdEvent {
  /// Constructeur pour créer un nouveau modèle d'événement
  const ThresholdEventModel({
    super.id,
    required super.temperature,
    required super.humidity,
    required super.timestamp,
    required super.eventType,
    required super.thresholdHigh,
    required super.thresholdLow,
    super.hiveId,
    super.apiaryId,
    super.isRead,
  });

  /// Constructeur à partir des données Firebase Realtime Database
  factory ThresholdEventModel.fromRealtimeDB(Map<String, dynamic> data,
      [String? key]) {
    ThresholdEventType type;

    // Déterminer le type d'événement
    final eventStr = data['event'] as String? ?? 'threshold_exceeded';
    if (eventStr == 'threshold_exceeded') {
      type = ThresholdEventType.exceeded;
    } else {
      type = ThresholdEventType.normal;
    }

    return ThresholdEventModel(
      id: key,
      temperature: (data['temperature'] as num).toDouble(),
      humidity: (data['humidity'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
      eventType: type,
      thresholdHigh: (data['threshold_high'] as num?)?.toDouble() ?? 30.0,
      thresholdLow: (data['threshold_low'] as num?)?.toDouble() ?? 15.0,
      hiveId: data['hive_id'] as String?,
      apiaryId: data['apiary_id'] as String?,
      isRead: data['is_read'] as bool? ?? false,
    );
  }

  /// Constructeur à partir des données Firestore
  factory ThresholdEventModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    ThresholdEventType type;

    // Déterminer le type d'événement
    final eventStr = data['event'] as String? ?? 'threshold_exceeded';
    if (eventStr == 'threshold_exceeded') {
      type = ThresholdEventType.exceeded;
    } else {
      type = ThresholdEventType.normal;
    }

    return ThresholdEventModel(
      id: id,
      temperature: (data['temperature'] as num).toDouble(),
      humidity: (data['humidity'] as num).toDouble(),
      timestamp: data['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : (data['timestamp'] as Timestamp).toDate(),
      eventType: type,
      thresholdHigh: (data['threshold_high'] as num?)?.toDouble() ?? 30.0,
      thresholdLow: (data['threshold_low'] as num?)?.toDouble() ?? 15.0,
      hiveId: data['hive_id'] as String?,
      apiaryId: data['apiary_id'] as String?,
      isRead: data['is_read'] as bool? ?? false,
    );
  }

  /// Convertir en Map pour Firebase
  Map<String, dynamic> toMap() {
    String eventStr;

    switch (eventType) {
      case ThresholdEventType.exceeded:
        eventStr = 'threshold_exceeded';
        break;
      case ThresholdEventType.normal:
        eventStr = 'threshold_normal';
        break;
    }

    return {
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'event': eventStr,
      'threshold_high': thresholdHigh,
      'threshold_low': thresholdLow,
      'hive_id': hiveId,
      'apiary_id': apiaryId,
      'is_read': isRead,
    };
  }

  /// Crée un modèle à partir d'une entité
  factory ThresholdEventModel.fromEntity(ThresholdEvent entity) {
    return ThresholdEventModel(
      id: entity.id,
      temperature: entity.temperature,
      humidity: entity.humidity,
      timestamp: entity.timestamp,
      eventType: entity.eventType,
      thresholdHigh: entity.thresholdHigh,
      thresholdLow: entity.thresholdLow,
      hiveId: entity.hiveId,
      apiaryId: entity.apiaryId,
      isRead: entity.isRead,
    );
  }

  /// Crée une copie du modèle avec certains attributs modifiés
  @override
  ThresholdEventModel copyWith({
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
    return ThresholdEventModel(
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
}
