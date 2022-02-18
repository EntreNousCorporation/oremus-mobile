
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:oremusapp/app/modules/splashscreen/binding/splashscreen_binding.dart';
import 'package:oremusapp/app/modules/splashscreen/views/splashscreen_screen.dart';

part './app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASHSCREEN,
      page: () => const SplashscreenScreen(),
      binding: SplashscreenBinding(),
      transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const SplashscreenScreen(),
    ),
  ];
}
