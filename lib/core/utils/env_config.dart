import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseDatabaseUrl =>
      dotenv.env['FIREBASE_DATABASE_URL'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get appName => dotenv.env['APP_NAME'] ?? 'RC Mobile App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}
