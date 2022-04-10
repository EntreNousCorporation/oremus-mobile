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

  //PAROISSE
  static const PAROISSE_MENU = '/paroisse-menu';
  static const PAROISSE_MENU_DETAIL = '/paroisse-menu-detail';

  //PROFILE
  static const EDIT_PASSWORD = '/edit-password';
  static const EDIT_PROFILE = '/edit-profile';
}
