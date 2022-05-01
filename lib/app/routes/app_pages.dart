import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:oremusapp/app/modules/customhome/binding/custom_home_binding.dart';
import 'package:oremusapp/app/modules/customhome/views/custom_home_screen.dart';
import 'package:oremusapp/app/modules/diocese/binding/diocese_binding.dart';
import 'package:oremusapp/app/modules/diocese/views/diocese_screen.dart';
import 'package:oremusapp/app/modules/editpassword/binding/edit_password_binding.dart';
import 'package:oremusapp/app/modules/editpassword/views/edit_password_screen.dart';
import 'package:oremusapp/app/modules/favorite/binding/favorite_binding.dart';
import 'package:oremusapp/app/modules/favorite/views/favorites_screen.dart';
import 'package:oremusapp/app/modules/home/binding/home_binding.dart';
import 'package:oremusapp/app/modules/home/views/home_screen.dart';
import 'package:oremusapp/app/modules/paroisse/binding/filter_paroisse_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_activity_movement_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_map_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_menu_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_menu_detail_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_office_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_presby_team_binding.dart';
import 'package:oremusapp/app/modules/paroisse/views/filter/filter_paroisse_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_map_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_activity_movement_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_confession_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_menu_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_messe_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_office_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_presby_team_screen.dart';
import 'package:oremusapp/app/modules/profile/binding/edit_profile_binding.dart';
import 'package:oremusapp/app/modules/profile/binding/profile_binding.dart';
import 'package:oremusapp/app/modules/profile/views/edit_profile_screen.dart';
import 'package:oremusapp/app/modules/resetpassword/bindings/init_reset_password_binding.dart';
import 'package:oremusapp/app/modules/resetpassword/bindings/otp_binding.dart';
import 'package:oremusapp/app/modules/resetpassword/bindings/reset_password_binding.dart';
import 'package:oremusapp/app/modules/resetpassword/views/init_reset_password_screen.dart';
import 'package:oremusapp/app/modules/resetpassword/views/otp_screen.dart';
import 'package:oremusapp/app/modules/resetpassword/views/reset_password_screen.dart';
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
      name: Routes.INIT_RESET_PASSWORD,
      page: () => const InitResetPasswordScreen(),
      binding: InitResetPasswordBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.CHECK_OTP,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_MENU,
      page: () => const ParoisseMenuScreen(),
      binding: ParoisseMenuBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.FILTER_PAROISSE,
      page: () => const FilterParoisseScreen(),
      binding: FilterParoisseBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PAROISSE_CONFESSION,
      page: () => const ParoisseConfessionScreen(),
      binding: ParoisseMenuDetailBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_MESSE,
      page: () => const ParoisseMesseScreen(),
      binding: ParoisseMenuDetailBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_OFFICE,
      page: () => const ParoisseOfficeScreen(),
      binding: ParoisseOfficeBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_MAP,
      page: () => const ParoisseMapScreen(),
      binding: ParoisseMapBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_ACTIVITY_MOVEMENT,
      page: () => const ParoisseActivityMovementScreen(),
      binding: ParoisseActivityMovementBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.PAROISSE_PRESBY_TEAM,
      page: () => const ParoisseBresbyTeamScreen(),
      binding: ParoissePresbyTeamBinding(),
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
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesScreen(),
      binding: FavoriteBinding(),
      transition: Transition.circularReveal,
    ),
  ];
}
