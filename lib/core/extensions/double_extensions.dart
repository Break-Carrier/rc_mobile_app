/// Extensions pour les valeurs numériques
extension DoubleExtensions on double {
  /// Formate la température avec l'unité
  String toTemperatureString() {
    return '${toStringAsFixed(1)}°C';
  }

  /// Formate l'humidité avec l'unité
  String toHumidityString() {
    return '${toStringAsFixed(1)}%';
  }

  /// Formate un nombre avec une précision donnée
  String toFormattedString([int precision = 1]) {
    return toStringAsFixed(precision);
  }

  /// Vérifie si une température est dans la plage normale
  bool get isNormalTemperature {
    return this >= 15.0 && this <= 35.0;
  }

  /// Vérifie si une humidité est dans la plage normale
  bool get isNormalHumidity {
    return this >= 40.0 && this <= 70.0;
  }

  /// Retourne la couleur associée à une température
  String get temperatureColor {
    if (this < 10) return 'blue';
    if (this < 20) return 'lightblue';
    if (this < 30) return 'green';
    if (this < 35) return 'orange';
    return 'red';
  }

  /// Retourne l'état de la température
  String get temperatureStatus {
    if (this < 15) return 'Très froid';
    if (this < 20) return 'Froid';
    if (this < 25) return 'Optimal';
    if (this < 30) return 'Chaud';
    if (this < 35) return 'Très chaud';
    return 'Critique';
  }
}
