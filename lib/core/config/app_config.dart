/// Configuration centralisée de l'application
class AppConfig {
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration dataRefreshInterval = Duration(seconds: 30);
  static const Duration chartUpdateInterval = Duration(seconds: 15);

  // Seuils par défaut
  static const double defaultLowThreshold = 15.0;
  static const double defaultHighThreshold = 30.0;
  static const double defaultHysteresisOffset = 0.5;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxEventsPerPage = 50;

  // Chart
  static const int maxChartDataPoints = 100;
  static const Duration defaultChartTimeRange = Duration(hours: 24);

  // Mock data
  static const bool useMockData = true; // À basculer selon l'environnement
  static const int mockDataPoints = 50;

  // Firebase
  static const Duration firebaseTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultCardMargin = 16.0;
  static const double defaultPadding = 8.0;

  // Validation
  static const double minTemperature = -50.0;
  static const double maxTemperature = 100.0;
  static const double minHumidity = 0.0;
  static const double maxHumidity = 100.0;

  // Messages d'erreur
  static const String genericErrorMessage =
      'Une erreur inattendue s\'est produite';
  static const String networkErrorMessage =
      'Erreur de connexion. Vérifiez votre connexion internet.';
  static const String timeoutErrorMessage =
      'Délai d\'attente dépassé. Veuillez réessayer.';
  static const String noDataMessage = 'Aucune donnée disponible';

  // Environnement
  static bool get isDevelopment => const String.fromEnvironment('ENV') == 'dev';
  static bool get isProduction => const String.fromEnvironment('ENV') == 'prod';
}
