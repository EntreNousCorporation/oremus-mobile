abstract class AppConstants {

  //ENVIRONNEMENT DE DEV
  static const ENV_DEV = 'dev';
  static const ENV_PROD = 'prod';

  static const KEY_LIST_FAVORITES = 'LIST_FAVORITES';
  static const KEY_USER_LOG_INFOS = 'USER_LOG_INFO';
  static const KEY_USER_INFOS = 'USER_INFOS';
  static const FCM_TOKEN = 'FCM_TOKEN';

  static const APP_NAME = 'OREMUS';

  //CONNECTIVITY
  static const REQUEST_TIMEOUT = 2 * 60; //seconds

  //HIVE
  static const BOX_NAME = "oremusBox";
  static const STORAGE_KEY = "oremusKey";

  //VALIDATOR
  static const INPUT_NUM_REGEX = "[0-9\\s]";
  static const INPUT_NAME_REGEX = "[a-zA-Z\\s'’-]";
  //static const INPUT_NAME_REGEX = "[a-zA-Z\\s’`'´-]";

  //CREDENTIALS
  static const KEY_TOKEN = "KEY_TOKEN";

  //PAGGING
  static const PAGING_SIZE = 10;

  //DRAWER MENU INDEX
  static const HOME = 0;
  static const PROFILE = 1;
  static const SHARE_APP = 2;
  static const PROMO = 3;
  static const FAQ = 4;
  static const CONTACTS = 5;
  static const ABOUT = 6;

  //LITURGICAL CELEBRATION
  static const EASTER_MASS = 'EASTER_MASS'; //Messe de Pâques
  static const EASTER_VIGIL = 'EASTER_VIGIL'; //Veillée Pascale
  static const MASS = 'MASS'; //Messe
  static const HOLY_THURSDAY = 'HOLY_THURSDAY'; //Jeudi Saint
  static const SACRAMENT = 'SACRAMENT'; //Sacrement
  static const CONFESSION = 'CONFESSION'; //Confession

  static const SPECIALS_MASSES = [
    EASTER_MASS,
    EASTER_VIGIL,
    HOLY_THURSDAY,
    SACRAMENT,
  ];
}
