class SensorReading {
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory SensorReading.fromMap(Map<String, dynamic> map) {
    return SensorReading(
      temperature: map['temperature']?.toDouble() ?? 0.0,
      humidity: map['humidity']?.toDouble() ?? 0.0,
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp,
    };
  }
}
