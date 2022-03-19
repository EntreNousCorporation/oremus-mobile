import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/lang/en_US.dart';
import 'package:oremusapp/app/commons/lang/fr_FR.dart';


class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static const fallbackLocale = Locale('fr', 'FR');

  @override
  Map<String, Map<String, String>> get keys => {
        'fr_FR': fr_FR,
        'en_US': en_US,
  };
}
