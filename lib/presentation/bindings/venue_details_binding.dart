import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../data/repositories/venue_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../controllers/venue_details_controller.dart';

class VenueDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(DioClient.instance));
    }

    Get.lazyPut<VenueRepository>(() => VenueRepositoryImpl(Get.find<ApiService>()));
    Get.lazyPut<BookingRepository>(() => BookingRepositoryImpl(Get.find<ApiService>(), StorageService.instance));
    
    Get.lazyPut<VenueDetailsController>(() => VenueDetailsController(
      Get.find<VenueRepository>(),
      Get.find<BookingRepository>(),
    ));
  }
}
