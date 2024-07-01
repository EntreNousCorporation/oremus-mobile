part of './app_pages.dart';

abstract class Routes {
  static const SPLASHSCREEN = '/';
  static const CUSTOM_HOME = '/custom-home';
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

  //FAVORIS
  static const FAVORITES = '/favorites';

  static const PRAY = '/pray';
}
