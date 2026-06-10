import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = StorageService.instance.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear local auth session
      StorageService.instance.clearAuth();
      // Redirect to login screen
      if (getx.Get.currentRoute != Routes.login) {
        getx.Get.offAllNamed(Routes.login);
      }
    }
    super.onError(err, handler);
  }
}
