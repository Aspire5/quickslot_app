class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.example.com/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String users = '/users';
  static const String login = '/auth/login';
}
