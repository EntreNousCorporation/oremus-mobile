import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in_up.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/controller/mass_request_track_claim_controller.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/views/widget/claim_item.dart';
import 'package:oremusapp/generated/assets.dart';

class MassRequestTrackClaimScreen extends StatelessWidget {
  const MassRequestTrackClaimScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<MassRequestTrackClaimController>(builder: (_) {
        return KeyboardDismisser(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: AppConstants.kExpandedHeight,
                    floating: false,
                    pinned: true,
                    backgroundColor: colorGreen,
                    elevation: 10,
                    shadowColor: colorGrey2.withOpacity(0.8),
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                    ),
                    actions: [
                      LikeButton(
                        isLiked: _.paroisseSelected.value.isFavorite,
                        onTap: (isLiked) async {
                          log('isLiked => $isLiked');
                          _.paroisseSelected.value.isFavorite = !isLiked;
                          if (isLiked) {
                            _.removeFavorite(_.paroisseSelected.value, isLiked);
                          } else {
                            _.saveFavorite(_.paroisseSelected.value, isLiked);
                          }
                          return !isLiked;
                        },
                        size: 25,
                        circleColor: const CircleColor(
                            start: Color(0xff93291E), end: Color(0xFFED213A)),
                        bubblesColor: const BubblesColor(
                          dotPrimaryColor: Color(0xFFED213A),
                          dotSecondaryColor: Color(0xff93291E),
                        ),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color:
                                isLiked ? const Color(0xFFED213A) : colorWhite,
                            size: 25,
                          );
                        },
                      ),
                      Separators.minimunHorizontal(),
                      IconButton(
                        onPressed: () {
                          _.goToMap();
                        },
                        icon: const Icon(Icons.map_rounded),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${_.paroisseSelected.value.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: colorWhite),
                        ),
                      ),
                      background: (_.paroisseSelected.value.coverImage?.link
                                  ?.isNotEmpty ==
                              true)
                          ? Stack(
                              children: [
                                Hero(
                                  tag:
                                      'tag${_.paroisseSelected.value.identifier}',
                                  child: CachedNetworkImage(
                                    width: Get.width,
                                    height: Get.width,
                                    imageUrl: _.paroisseSelected.value
                                            .coverImage?.link ??
                                        '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        LottieLoadingView(size: Get.width / 6),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Container(
                                  height: Get.width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black54.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                Hero(
                                  tag:
                                      'tag${_.paroisseSelected.value.identifier}',
                                  child: Image.asset(
                                    Assets.imagesBgLogin,
                                    width: Get.width,
                                    height: Get.width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  height: Get.width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black54.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 8)),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Separators.minimunVertical(),
                        Text(
                          'Suivi de réclamation',
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.eighteen,
                            textColor: colorGreenSemiLight,
                          ),
                        ),
                        Separators.minimunVertical(),
                        _.isDataProcessing.isTrue
                            ? Column(
                          children: [
                            Separators.customSizeVertical(
                                Get.height * 0.15),
                            LottieLoadingView(
                              size: Get.width / 4,
                            ),
                          ],
                        )
                            : _.hasData.isTrue
                            ? FadeInUp(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 0,
                                  left: 16,
                                  right: 16,
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var claimData = _.claims[index];
                                    return ClaimItem(claimData: claimData);
                                  },
                                  separatorBuilder: (context, index) {
                                    return Separators.normalVertical();
                                  },
                                  itemCount: _.claims.length,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Column(
                          children: [
                            Separators.customSizeVertical(
                                Get.height * 0.15),
                            NotFoundScreen(
                              message:
                              "Aucune réclamation enregistrée pour l'instant !",
                            ),
                          ],
                        ),
                        Separators.minimunVertical(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
