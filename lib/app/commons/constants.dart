import 'package:get/get.dart';

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
  static var kExpandedHeight = Get.width / 1.75; //seconds

  //HIVE
  static const BOX_NAME = "oremusBox";
  static const STORAGE_KEY = "oremusKey";
  static const KEY_LANGUAGE = "KEY_LANGUAGE";

  //VALIDATOR
  static const INPUT_NUM_REGEX = "[0-9\\s]";
  static const INPUT_NAME_REGEX = "[a-zA-Z\\s'’-]";
  //static const INPUT_NAME_REGEX = "[a-zA-Z\\s’`'´-]";

  //CREDENTIALS
  static const KEY_TOKEN = "KEY_TOKEN";

  //PAGGING
  static const PAGING_SIZE_1000 = 1000;
  static const PRAY_PAGING_SIZE = 15;
  static const MASS_REQUEST_PAGING_SIZE = 10;

  //DRAWER MENU INDEX
  static const HOME = 0;
  static const PROFILE = 1;
  static const SHARE_APP = 2;
  static const PROMO = 3;
  static const FAQ = 4;
  static const CONTACTS = 5;
  static const ABOUT = 6;
  static const PRAY = 7;
  static const SIGNIN = 8;

  //LITURGICAL CELEBRATION
  static const SPECIAL_MASS = 'SPECIAL_MASS';
  static const MASS = 'MASS'; //Messe
  static const CONFESSION = 'CONFESSION'; //Confession
  static const SPECIAL_CONFESSION = 'SPECIAL_CONFESSION'; //Veillée Pascale
  static const DEMANDE_MESSE = 'demande_de_messe'; //DEMANDE_MESSE

  static const APP_SHARE_MSG = "Télécharge gratuitement l'appli #Oremus et accède à tes paroisses du bout du doigt! Lien de téléchargement📲: {link}"; //DEMANDE_MESSE
}
