import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Register dependencies if not registered globally
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(DioClient.instance));
    }
    
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find<ApiService>(), StorageService.instance));
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthRepository>()));
  }
}
