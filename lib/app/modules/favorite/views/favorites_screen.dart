import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/favorite/controller/favorite_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/paroisse_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<FavoriteController>(
            initState: (state) {},
            builder: (_) {
              return WillPopScope(
                onWillPop: () async => false,
                child: KeyboardDismisser(
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    appBar: AppBar(
                      elevation: 10,
                      shadowColor: colorGrey2.withOpacity(0.8),
                      leading: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                      title: Text(
                        'Mes favoris',
                        style: TextStyles.montserratBold(
                            textSize: TextSizes.sixteen, textColor: colorWhite),
                      ),
                      centerTitle: true,
                      backgroundColor: colorGreen,
                    ),
                    body: Container(
                      color: colorGrey4,
                      width: double.infinity,
                      child: Column(
                        children: [
                          _.favorites.isNotEmpty
                              ? Expanded(
                                  child: FadeIn(
                                    duration: const Duration(milliseconds: 500),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 0,
                                          bottom: 0,
                                          left: 16,
                                          right: 16),
                                      child: ListView.builder(
                                          shrinkWrap: false,
                                          itemCount: _.favorites.length,
                                          itemBuilder: (builder, index) {
                                            var paroisse = _.favorites[index];
                                            return ParoisseItem(
                                              paroisse: paroisse,
                                              index: index,
                                              fromFavoriteUI: true,
                                            );
                                          }),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: NotFoundScreen(
                                  message: "Aucun favoris pour le moment",
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
