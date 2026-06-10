import 'package:get/get.dart';
import '../data/services/storage_service.dart';
import '../presentation/bindings/auth_binding.dart';
import '../presentation/bindings/dashboard_binding.dart';
import '../presentation/bindings/venue_details_binding.dart';
import '../presentation/views/login_view.dart';
import '../presentation/views/dashboard_view.dart';
import '../presentation/views/venue_details_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  // Determine initial route based on session state
  static String get initial =>
      StorageService.instance.getToken() != null ? Routes.dashboard : Routes.login;

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.venueDetails,
      page: () => const VenueDetailsView(),
      binding: VenueDetailsBinding(),
    ),
  ];
}
