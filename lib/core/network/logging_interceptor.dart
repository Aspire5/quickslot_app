import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> [HTTP] ${options.method.toUpperCase()} ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('Body: ${options.data}');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [HTTP] ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
      debugPrint('Response: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP ERROR] ${err.response?.statusCode} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');
      debugPrint('Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('Response Data: ${err.response?.data}');
      }
    }
    super.onError(err, handler);
  }
}
