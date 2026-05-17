/// URLs et configuration API (Laravel) — mock pour le MVP.
abstract final class ApiConstants {
  /// Base URL future API REST Laravel.
  static const String baseUrl = "https://api.ozelservices.bj/v1";

  /// Timeout Dio (secondes).
  static const int connectTimeoutSeconds = 20;
  static const int receiveTimeoutSeconds = 20;
}
