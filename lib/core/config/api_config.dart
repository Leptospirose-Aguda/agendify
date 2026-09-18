abstract final class ApiConfig {
  /// Pode ser sobrescrita em tempo de execução:
  /// flutter run --dart-define=API_BASE_URL=http://localhost:8080/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
}
