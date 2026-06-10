import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../domain/repositories/user_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<ApiService>(() => ApiService(DioClient.instance));
    
    // Repositories
    Get.lazyPut<UserRepository>(() => UserRepositoryImpl(Get.find<ApiService>()));
    
    // Controllers
    Get.lazyPut<HomeController>(() => HomeController(Get.find<UserRepository>()));
  }
}
