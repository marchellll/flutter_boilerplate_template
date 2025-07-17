class AppConstants {
  // API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String apiVersion = '/v1';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String todosBoxKey = 'todos';

  // Network
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Routes
  static const String homeRoute = '/';
  static const String todoRoute = '/todo';
  static const String debugRoute = '/debug';

  // Error Messages
  static const String networkError = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String cacheError = 'Cache error occurred';
  static const String unknownError = 'Unknown error occurred';
}
