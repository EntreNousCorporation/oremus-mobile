part of './app_pages.dart';

abstract class Routes {
  static const SPLASHSCREEN = '/';
  static const CUSTOM_HOME = '/custom-home';
  static const CUSTOM_HOME_NEW = '/custom-home-new';
  static const HOME = '/home';
  static const DIOCESE = '/diocese';
  static const INITIAL = '/initial';

  //AUTH
  static const SIGNIN = '/signin';
  static const SIGNUP = '/signup';
  static const INIT_RESET_PASSWORD = '/init-reset-password';
  static const CHECK_OTP = '/check-otp';
  static const RESET_PASSWORD = '/reset-password';

  //PAROISSE
  static const PAROISSE_MENU = '/paroisse-menu';
  static const PAROISSE_MESSE = '/paroisse-messe';
  static const PAROISSE_MASS_REQUEST_MENU = '/paroisse-mass-request-menu';
  static const PAROISSE_DONATION_MENU = '/paroisse-donation-menu';
  static const PAROISSE_CONFESSION = '/paroisse-confession';
  static const PAROISSE_OFFICE = '/paroisse-office';
  static const PAROISSE_MAP = '/paroisse-map';
  static const PAROISSE_ACTIVITY_MOVEMENT = '/paroisse-activity-movement';
  static const PAROISSE_PRESBY_TEAM = '/paroisse-presby-team';
  static const PAROISSE_CONTACT = '/paroisse-contact';
  static const FILTER_PAROISSE = '/filter-paroisse';

  //PROFILE
  static const EDIT_PASSWORD = '/edit-password';
  static const EDIT_PROFILE = '/edit-profile';
  static const PROFILE = '/profile';

  //FAVORIS
  static const FAVORITES = '/favorites';

  //PRAY
  static const PRAY = '/pray';

  //ASK MASS
  static const MASS_REQUEST = '/mass-request';
  static const MASS_REQUEST_HISTORY = '/mass-request-history';
  static const MASS_REQUEST_HISTORY_DETAIL = '/mass-request-history-detail';
  static const FILTER_MASS_REQUEST_HISTORY = '/filter-mass-request-history';
  static const FILTER_MASS_REQUEST_CHOOSE_DATE = '/filter-mass-request-choose-date';
  static const FILTER_CHOOSE_WORSHIP = '/filter-choose-worship';
  static const MASS_REQUEST_CLAIM = '/mass-request-claim';
  static const MASS_REQUEST_TRACK_CLAIM = '/mass-request-track-claim';
  static const MASS_REQUEST_TRACK_CLAIM_DETAILS = '/mass-request-track-claim-details';
  static const MASS_REQUEST_WITHOUT_WORSHIP = '/mass-request-without-worship';
  static const MASS_REQUEST_MENU = '/mass-request-menu';
  static const MASS_REQUEST_RECAP = '/mass-request-recap';

  //DONATION
  static const DONATION = '/donation';
  static const DONATION_HISTORY = '/donation-history';
  static const DONATION_HISTORY_DETAIL = '/donation-history-detail';
  static const FILTER_DONATION_HISTORY = '/filter-donation-history';
  static const FILTER_DONATION_CHOOSE_DATE = '/filter-donation-choose-date';
  static const FILTER_DONATION_CHOOSE_WORSHIP = '/filter-donation-choose-worship';
  static const DONATION_WITHOUT_WORSHIP = '/donation-without-worship';
  static const DONATION_MENU = '/donation-menu';
  static const DONATION_RECAP = '/donation-recap';

  //PAYMENT
  static const PAYMENT = '/payment';
  static const PAYMENT_SUCCESS = '/payment-success';
  static const PAYMENT_ERROR = '/payment-error';
  static const PAYMENT_PROCESSING = '/payment-processing';

  //REPORT PROBLEM
  static const REPORT_PROBLEM = '/report-problem';

  static const FAQ = '/faq';
  static const ABOUT = '/about';

  static const LIFE_PLAN = '/life-plan';
  static const LIFE_PLAN_FORM = '/life-plan-form';
  static const ACTIVITY_SELECTION = '/life-plan-activities';
}
