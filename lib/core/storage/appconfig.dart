class AppConfig {
  static const String baseUrl = "http://192.168.109.14:8000/api";
  static const String apiKey = 'E4B73FEE-F492-4607-A38D-852B0EBC91C9';

  /// Origin for uploaded files (storage paths returned by the API).
  static String get storageBaseUrl => baseUrl.replaceFirst(RegExp(r'/api$'), '');
}
