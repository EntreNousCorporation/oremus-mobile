import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/flow_delegate.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/favorite/controller/favorite_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class ParoisseItem extends StatelessWidget {
  ParoisseItem({
    Key? key,
    required this.paroisse,
    required this.index,
    this.fromFavoriteUI = false,
  }) : super(key: key);

  final bool fromFavoriteUI;
  final ContentPlace? paroisse;
  final int index;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseController>(
      builder: (logic) {
        return Padding(
          padding: const EdgeInsets.only(
            top: .0,
            bottom: .0,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: 2, // Légère élévation pour un effet de carte
            color: colorWhite,
            shadowColor: colorGrey2.withValues(alpha: 0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Utilisation d'InkWell au lieu de GestureDetector pour avoir un feedback visuel
                InkWell(
                  onTap: () {
                    logic.goToParoisseDetail(paroisse, index);
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Hero(
                        transitionOnUserGestures: true,
                        tag: 'tag$index',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                          child: SizedBox(
                            height: Get.width / 2.2,
                            width: double.infinity,
                            child: (paroisse?.coverImage?.link?.isNotEmpty == true)
                                ? Flow(
                              delegate: ParallaxFlowDelegate(
                                scrollable: Scrollable.of(context),
                                listItemContext: context,
                                backgroundImageKey: _backgroundImageKey,
                              ),
                              children: [
                                CachedNetworkImage(
                                  key: _backgroundImageKey,
                                  imageUrl: paroisse?.coverImage?.link ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => SizedBox(
                                      width: Get.width / 4,
                                      height: Get.width / 4,
                                      child: LottieLoadingView(size: Get.width / 6)),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ],
                            )
                                : Image.asset(
                              'assets/images/bg_login.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Overlay avec le nom de la paroisse
                      Container(
                        width: Get.width,
                        height: Get.width / 2.2,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // Dégradé du bas vers le haut pour un meilleur contraste avec le texte
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Get.width / 10),
                          child: Text(
                            paroisse?.name ?? 'Paroisse',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.twenty_four,
                              textColor: colorWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                fromFavoriteUI ? Container() : Separators.minimunVertical(),
                // Informations sur la paroisse (diocèse et municipalité)
                Padding(
                  padding: const EdgeInsets.all(12.0), // Espace intérieur plus important
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          paroisse?.diocese?.name ?? 'Diocèse',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.thirteen,
                            textColor: colorBlack,
                          ),
                        ),
                      ),
                      Separators.normalHorizontal(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Bouton de municipalité - Utilise InkWell enveloppé dans Material pour les effets de touch
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                logic.goToParoisseDetail(paroisse, index);
                              },
                              borderRadius: BorderRadius.circular(3),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: colorGreenSemiLight,
                                ),
                                child: Text(
                                  paroisse?.address?.municipality ?? 'N/A',
                                  style: TextStyles.montserratBold(
                                    textSize: TextSizes.eleven,
                                    textColor: colorWhite,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fromFavoriteUI ? 0 : 12, // Espacement plus large
                          ),
                          // Bouton de favoris
                          fromFavoriteUI
                              ? GetBuilder<FavoriteController>(
                            builder: (logic) {
                              return IconButton(
                                constraints: const BoxConstraints(maxWidth: 30),
                                alignment: AlignmentDirectional.center,
                                onPressed: () {
                                  // Assure-toi que le contrôleur est instancié et accessible
                                  if (logic != null) {
                                    logic.removeToFavoriteList(paroisse, index);
                                  }
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Color(0xFFED213A),
                                  size: 25,
                                ),
                              );
                            },
                          )
                              : LikeButton(
                            isLiked: paroisse?.isFavorite ?? false, // Protection contre les null
                            onTap: (isLiked) async {
                              if (paroisse != null&& paroisse?.isFavorite != null) {
                                paroisse?.isFavorite = !isLiked;
                                if (isLiked) {
                                  logic.removeFavorite(paroisse);
                                } else {
                                  logic.saveFavorite(paroisse);
                                }
                                return !isLiked;
                              }
                              return isLiked; // Si la paroisse est null, ne change pas l'état
                            },
                            size: 25,
                            circleColor: const CircleColor(
                              start: Color(0xff93291E),
                              end: Color(0xFFED213A),
                            ),
                            bubblesColor: const BubblesColor(
                              dotPrimaryColor: Color(0xFFED213A),
                              dotSecondaryColor: Color(0xff93291E),
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? const Color(0xFFED213A) : colorGrey1,
                                size: 25,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}