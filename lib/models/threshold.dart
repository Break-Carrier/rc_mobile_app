class Threshold {
  final double value;
  final DateTime timestamp;

  Threshold({
    required this.value,
    required this.timestamp,
  });

  factory Threshold.fromMap(Map<String, dynamic> map) {
    return Threshold(
      value: map['value']?.toDouble() ?? 0.0,
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'timestamp': timestamp,
    };
  }
}
