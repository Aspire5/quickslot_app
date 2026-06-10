import 'package:get/get.dart';
import '../presentation/bindings/home_binding.dart';
import '../presentation/views/home_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
