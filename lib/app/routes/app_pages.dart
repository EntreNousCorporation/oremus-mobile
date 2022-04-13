import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:oremusapp/app/modules/customhome/binding/custom_home_binding.dart';
import 'package:oremusapp/app/modules/customhome/views/custom_home_screen.dart';
import 'package:oremusapp/app/modules/diocese/binding/diocese_binding.dart';
import 'package:oremusapp/app/modules/diocese/views/diocese_screen.dart';
import 'package:oremusapp/app/modules/editpassword/binding/edit_password_binding.dart';
import 'package:oremusapp/app/modules/editpassword/views/edit_password_screen.dart';
import 'package:oremusapp/app/modules/faq/binding/faq_binding.dart';
import 'package:oremusapp/app/modules/formation/binding/formation_binding.dart';
import 'package:oremusapp/app/modules/home/binding/home_binding.dart';
import 'package:oremusapp/app/modules/home/views/home_screen.dart';
import 'package:oremusapp/app/modules/landing/binding/landing_binding.dart';
import 'package:oremusapp/app/modules/landing/views/landing_screen.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_map_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_menu_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_menu_detail_binding.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_map_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu_detail_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu_screen.dart';
import 'package:oremusapp/app/modules/profile/binding/edit_profile_binding.dart';
import 'package:oremusapp/app/modules/profile/binding/profile_binding.dart';
import 'package:oremusapp/app/modules/profile/views/edit_profile_screen.dart';
import 'package:oremusapp/app/modules/service/binding/service_binding.dart';
import 'package:oremusapp/app/modules/signin/binding/signin_binding.dart';
import 'package:oremusapp/app/modules/signin/views/signin_screen.dart';
import 'package:oremusapp/app/modules/signup/binding/signup_binding.dart';
import 'package:oremusapp/app/modules/signup/views/signup_screen.dart';
import 'package:oremusapp/app/modules/splashscreen/binding/splashscreen_binding.dart';
import 'package:oremusapp/app/modules/splashscreen/views/splashscreen_screen.dart';

part './app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASHSCREEN,
      page: () => const SplashscreenScreen(),
      binding: SplashscreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.CUSTOM_HOME,
      page: () => const CustomHomeScreen(),
      bindings: [
        CustomHomeBinding(),
        ParoisseBinding(),
        ProfileBinding(),
        FaqBinding(),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.INITIAL,
      page: () => LandingScreen(),
      bindings: [
        LandingBinding(),
        ParoisseBinding(),
        DioceseBinding(),
        FormationBinding(),
        ServiceBinding(),
      ],
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.DIOCESE,
      page: () => const DioceseScreen(),
      binding: DioceseBinding(),
    ),
    GetPage(
      name: Routes.SIGNIN,
      page: () => const SigninScreen(),
      binding: SigninBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_MENU,
      page: () => const ParoisseMenuScreen(),
      binding: ParoisseMenuBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PAROISSE_MENU_DETAIL,
      page: () => const ParoisseMenuDetailScreen(),
      binding: ParoisseMenuDetailBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_MAP,
      page: () => ParoisseMapScreen(),
      binding: ParoisseMapBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.EDIT_PASSWORD,
      page: () => const EditPasswordScreen(),
      binding: EditPasswordBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
      transition: Transition.circularReveal,
    ),
  ];
}
