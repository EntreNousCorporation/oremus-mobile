import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:oremusapp/app/modules/customhome/binding/custom_home_binding.dart';
import 'package:oremusapp/app/modules/customhome/views/custom_home_screen.dart';
import 'package:oremusapp/app/modules/diocese/binding/diocese_binding.dart';
import 'package:oremusapp/app/modules/diocese/views/diocese_screen.dart';
import 'package:oremusapp/app/modules/donation/binding/donation_binding.dart';
import 'package:oremusapp/app/modules/donation/binding/donation_menu_binding.dart';
import 'package:oremusapp/app/modules/donation/binding/donation_with_worship_binding.dart';
import 'package:oremusapp/app/modules/donation/binding/filter_donation_worship_binding.dart';
import 'package:oremusapp/app/modules/donation/views/donation_menu_screen.dart';
import 'package:oremusapp/app/modules/donation/views/donation_screen.dart';
import 'package:oremusapp/app/modules/donation/views/donation_with_worship_screen.dart';
import 'package:oremusapp/app/modules/donation/views/widget/filter_donation_worship_screen.dart';
import 'package:oremusapp/app/modules/donationhistory/binding/donation_history_binding.dart';
import 'package:oremusapp/app/modules/donationhistory/binding/donation_history_detail_binding.dart';
import 'package:oremusapp/app/modules/donationhistory/views/donation_history_detail_screen.dart';
import 'package:oremusapp/app/modules/donationhistory/views/donation_history_screen.dart';
import 'package:oremusapp/app/modules/editpassword/binding/edit_password_binding.dart';
import 'package:oremusapp/app/modules/editpassword/views/edit_password_screen.dart';
import 'package:oremusapp/app/modules/favorite/binding/favorite_binding.dart';
import 'package:oremusapp/app/modules/favorite/views/favorites_screen.dart';
import 'package:oremusapp/app/modules/massrequest/binding/filter_mass_request_date_binding.dart';
import 'package:oremusapp/app/modules/massrequest/binding/filter_mass_request_worship_binding.dart';
import 'package:oremusapp/app/modules/massrequest/binding/mass_request_binding.dart';
import 'package:oremusapp/app/modules/massrequest/binding/mass_request_menu_binding.dart';
import 'package:oremusapp/app/modules/massrequest/binding/mass_request_with_worship_binding.dart';
import 'package:oremusapp/app/modules/massrequest/views/mass_request_menu_screen.dart';
import 'package:oremusapp/app/modules/massrequest/views/mass_request_screen.dart';
import 'package:oremusapp/app/modules/massrequest/views/mass_request_with_worship_screen.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/filter_mass_request_date_screen.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/filter_mass_request_worship_screen.dart';
import 'package:oremusapp/app/modules/massrequestclaim/binding/mass_request_claim_binding.dart';
import 'package:oremusapp/app/modules/massrequestclaim/views/mass_request_claim_screen.dart';
import 'package:oremusapp/app/modules/massrequesthistory/binding/filter_mass_request_history_binding.dart';
import 'package:oremusapp/app/modules/massrequesthistory/binding/mass_request_history_binding.dart';
import 'package:oremusapp/app/modules/massrequesthistory/binding/mass_request_history_detail_binding.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/mass_request_history_detail_screen.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/mass_request_history_screen.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/filter_mass_request_history_screen.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/binding/mass_request_track_claim_binding.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/binding/mass_request_track_claim_detail_binding.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/views/mass_request_track_claim_detail_screen.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/views/mass_request_track_claim_screen.dart';
import 'package:oremusapp/app/modules/paroisse/binding/filter_paroisse_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_activity_movement_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_confession_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_contact_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_donation_menu_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_map_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_mass_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_mass_request_menu_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_menu_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_office_binding.dart';
import 'package:oremusapp/app/modules/paroisse/binding/paroisse_presby_team_binding.dart';
import 'package:oremusapp/app/modules/paroisse/views/filter/filter_paroisse_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_map_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/activity_movement/paroisse_activity_movement_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/confession/paroisse_type_confession_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/mass/paroisse_type_masse_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_contact_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_donation_menu_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_mass_request_menu_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_menu_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_office_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/paroisse_presby_team_screen.dart';
import 'package:oremusapp/app/modules/payment/binding/payment_binding.dart';
import 'package:oremusapp/app/modules/payment/binding/payment_status_binding.dart';
import 'package:oremusapp/app/modules/payment/views/payment_error_screen.dart';
import 'package:oremusapp/app/modules/payment/views/payment_screen.dart';
import 'package:oremusapp/app/modules/payment/views/payment_success_screen.dart';
import 'package:oremusapp/app/modules/pray/binding/pray_binding.dart';
import 'package:oremusapp/app/modules/pray/views/pray_screen.dart';
import 'package:oremusapp/app/modules/profile/binding/edit_profile_binding.dart';
import 'package:oremusapp/app/modules/profile/binding/profile_binding.dart';
import 'package:oremusapp/app/modules/profile/views/edit_profile_screen.dart';
import 'package:oremusapp/app/modules/reportproblem/binding/report_problem_binding.dart';
import 'package:oremusapp/app/modules/reportproblem/views/report_problem_screen.dart';
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
        MassRequestMenuBinding(),
        DonationMenuBinding(),
        ProfileBinding(),
        PrayBinding(),
      ],
      transition: Transition.circularReveal,
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
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.FILTER_PAROISSE,
      page: () => const FilterParoisseScreen(),
      binding: FilterParoisseBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PAROISSE_CONFESSION,
      page: () => const ParoisseTypeConfessionScreen(),
      binding: ParoisseConfessionBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAROISSE_MESSE,
      page: () => const ParoisseTypeMasseScreen(),
      binding: ParoisseMasseBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAROISSE_MASS_REQUEST_MENU,
      page: () => const ParoisseMassRequestMenuScreen(),
      binding: ParoisseMassRequestMenuBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAROISSE_DONATION_MENU,
      page: () => const ParoisseDonationMenuScreen(),
      binding: ParoisseDonationMenuBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAROISSE_OFFICE,
      page: () => const ParoisseOfficeScreen(),
      binding: ParoisseOfficeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
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
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAROISSE_PRESBY_TEAM,
      page: () => const ParoisseBresbyTeamScreen(),
      binding: ParoissePresbyTeamBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAROISSE_CONTACT,
      page: () => const ParoisseContactScreen(),
      binding: ParoisseContactBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
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
    GetPage(
      name: Routes.PRAY,
      page: () => const PrayScreen(),
      binding: PrayBinding(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: Routes.MASS_REQUEST,
      page: () => const MassRequestScreen(),
      binding: MassRequestBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MASS_REQUEST_HISTORY,
      page: () => const MassRequestHistoryScreen(),
      binding: MassRequestHistoryBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MASS_REQUEST_HISTORY_DETAIL,
      page: () => const MassRequestHistoryDetailScreen(),
      binding: MassRequestHistoryDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.FILTER_MASS_REQUEST_HISTORY,
      page: () => const FilterMassRequestHistoryScreen(),
      binding: FilterMassRequestHistoryBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.FILTER_MASS_REQUEST_CHOOSE_DATE,
      page: () => const FilterMassRequestDateScreen(),
      binding: FilterMassRequestDateBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.FILTER_MASS_REQUEST_CHOOSE_WORSHIP,
      page: () => const FilterMassRequestWorshipScreen(),
      binding: FilterMassRequestWorshipBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MASS_REQUEST_CLAIM,
      page: () => const MassRequestClaimScreen(),
      binding: MassRequestClaimBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MASS_REQUEST_TRACK_CLAIM,
      page: () => const MassRequestTrackClaimScreen(),
      binding: MassRequestTrackClaimBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MASS_REQUEST_TRACK_CLAIM_DETAILS,
      page: () => const MassRequestTrackClaimDetailScreen(),
      binding: MassRequestTrackClaimDetialsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MASS_REQUEST_WITHOUT_WORSHIP,
      page: () => const MassRequestWithWorshipScreen(),
      binding: MassRequestWithWorshipBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MASS_REQUEST_MENU,
      page: () => const MassRequestMenuScreen(),
      binding: MassRequestMenuBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.DONATION,
      page: () => const DonationScreen(),
      binding: DonationBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.DONATION_HISTORY,
      page: () => const DonationHistoryScreen(),
      binding: DonationHistoryBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.DONATION_HISTORY_DETAIL,
      page: () => const DonationHistoryDetailScreen(),
      binding: DonationHistoryDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.FILTER_DONATION_CHOOSE_WORSHIP,
      page: () => const FilterDonationWorshipScreen(),
      binding: FilterDonationWorshipBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.DONATION_WITHOUT_WORSHIP,
      page: () => const DonationWithWorshipScreen(),
      binding: DonationWithWorshipBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.DONATION_MENU,
      page: () => const DonationMenuScreen(),
      binding: DonationMenuBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAYMENT,
      page: () => const PaymentScreen(),
      binding: PaymentBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAYMENT_SUCCESS,
      page: () => const PaymentSuccessScreen(),
      binding: PaymentStatusBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PAYMENT_ERROR,
      page: () => const PaymentErrorScreen(),
      binding: PaymentStatusBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.REPORT_PROBLEM,
      page: () => const ReportProblemScreen(),
      binding: ReportProblemBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
