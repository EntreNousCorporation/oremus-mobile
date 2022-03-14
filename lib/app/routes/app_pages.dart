import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:oremusapp/app/modules/connexion/binding/connexion_binding.dart';
import 'package:oremusapp/app/modules/connexion/views/connexion_screen.dart';
import 'package:oremusapp/app/modules/home/binding/home_binding.dart';
import 'package:oremusapp/app/modules/home/views/home_screen.dart';
import 'package:oremusapp/app/modules/landing/views/landing_screen.dart';
import 'package:oremusapp/app/modules/splashscreen/binding/splashscreen_binding.dart';
import 'package:oremusapp/app/modules/splashscreen/views/splashscreen_screen.dart';

part './app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
        name: Routes.SPLASHSCREEN,
        page: () => const SplashscreenScreen(),
        binding: SplashscreenBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.INITIAL,
        page: () => LandingScreen(),
        bindings: [
          HomeBinding(),
        ],
        transition: Transition.zoom),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
        name: Routes.CONNEXION,
        page: () => const ConnexionScreen(),
        binding: ConnexionBinding(),
        transition: Transition.circularReveal),
  ];
}
