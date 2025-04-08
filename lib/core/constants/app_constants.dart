class AppConstants {
  // App Info
  static const String appName = 'RC Mobile App';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Sensor Thresholds
  static const double minTemperature = 15.0;
  static const double maxTemperature = 35.0;
  static const double minHumidity = 40.0;
  static const double maxHumidity = 80.0;

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Error Messages
  static const String genericError = 'Une erreur est survenue';
  static const String networkError = 'Erreur de connexion';
  static const String authError = 'Erreur d\'authentification';
  static const String dataError = 'Erreur de données';

  // Success Messages
  static const String saveSuccess = 'Enregistré avec succès';
  static const String deleteSuccess = 'Supprimé avec succès';
  static const String updateSuccess = 'Mis à jour avec succès';
}
