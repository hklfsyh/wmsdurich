// Configuration for Mock/API Mode
// Change this to switch between mock and real API

class AppConfig {
  // Set to true to use mock data, false to use real API
  static const bool useMockData = true;

  // API Base URL (when not using mock)
  static const String apiBaseUrl = 'https://your-api-url.com';

  // App version
  static const String appVersion = '1.0.0+mock';

  // Debug mode
  static const bool debugMode = true;
}
