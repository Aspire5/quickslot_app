import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api/v1';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001/api/v1';
    } else {
      return 'http://localhost:5001/api/v1';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/auth/login';
  static const String venues = '/venues';
  static const String bookings = '/bookings';
  static const String users = '/users';
}
