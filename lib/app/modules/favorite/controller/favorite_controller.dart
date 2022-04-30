import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoriteController extends GetxController {
  final ParoisseRepository paroisseRepository;

  FavoriteController({
    required this.paroisseRepository,
  });

  var favorites = RxList<ContentPlace>([]);

  final GlobalKey<AnimatedListState> key = GlobalKey();

  @override
  void onReady() {
    getAllFavorites();
    super.onReady();
  }

  getAllFavorites() {
    favorites.value = paroisseRepository.getAllFavorites();
    favorites.sort((a, b) => a.name!.compareTo(b.name!));
    log('favorites => ${favorites.length}');
  }

  removeToFavoriteList(ContentPlace paroisseToRemove, int index) {
    log('${paroisseToRemove.name}');
    showCustomDialog(Get.context!,
        message: 'Retirer «${paroisseToRemove.name}» des favoris ?',
        negativeLabel: 'Oui, Retirer', negativeCallBack: () {
      paroisseRepository.deleteFavorite(paroisseToRemove);
      key.currentState!.removeItem(index, (_, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            margin: const EdgeInsets.all(8),
            elevation: 0,
            color: colorWhite,
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              title: Text(
                "",
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.fourteen,
                  textColor: colorBlack,
                ),
              ),
            ),
          ),
        );
      }, duration: const Duration(seconds: 1));
      getAllFavorites();
    }, positiveLabel: 'Annuler', positiveCallBack: () {});
  }
}
